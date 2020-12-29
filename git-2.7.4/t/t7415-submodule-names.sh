#!/bin/sh

test_description='check handling of .. in submodule names

Exercise the name-checking function on a variety of names, and then give a
real-world setup that confirms we catch this in practice.
'
. ./test-lib.sh
. "$TEST_DIRECTORY"/lib-pack.sh

test_expect_success 'check names' '
	cat >expect <<-\EOF &&
	valid
	valid/with/paths
	EOF

	git submodule--helper check-name >actual <<-\EOF &&
	valid
	valid/with/paths

	../foo
	/../foo
	..\foo
	\..\foo
	foo/..
	foo/../
	foo\..
	foo\..\
	foo/../bar
	EOF

	test_cmp expect actual
'

test_expect_success 'create innocent subrepo' '
	git init innocent &&
	git -C innocent commit --allow-empty -m foo
'

test_expect_success 'submodule add refuses invalid names' '
	test_must_fail \
		git submodule add --name ../../modules/evil "$PWD/innocent" evil
'

test_expect_success 'add evil submodule' '
	git submodule add "$PWD/innocent" evil &&

	mkdir modules &&
	cp -r .git/modules/evil modules &&
	write_script modules/evil/hooks/post-checkout <<-\EOF &&
	echo >&2 "RUNNING POST CHECKOUT"
	EOF

	git config -f .gitmodules submodule.evil.update checkout &&
	git config -f .gitmodules --rename-section \
		submodule.evil submodule.../../modules/evil &&
	git add modules &&
	git commit -am evil
'

# This step seems like it shouldn't be necessary, since the payload is
# contained entirely in the evil submodule. But due to the vagaries of the
# submodule code, checking out the evil module will fail unless ".git/modules"
# exists. Adding another submodule (with a name that sorts before "evil") is an
# easy way to make sure this is the case in the victim clone.
test_expect_success 'add other submodule' '
	git submodule add "$PWD/innocent" another-module &&
	git add another-module &&
	git commit -am another
'

test_expect_success 'clone evil superproject' '
	test_might_fail git clone --recurse-submodules . victim >output 2>&1 &&
	cat output &&
	! grep "RUNNING POST CHECKOUT" output
'

test_expect_success 'fsck detects evil superproject' '
	test_must_fail git fsck
'

test_expect_success 'transfer.fsckObjects detects evil superproject (unpack)' '
	rm -rf dst.git &&
	git init --bare dst.git &&
	git -C dst.git config transfer.fsckObjects true &&
	test_must_fail git push dst.git HEAD
'

test_expect_success 'transfer.fsckObjects detects evil superproject (index)' '
	rm -rf dst.git &&
	git init --bare dst.git &&
	git -C dst.git config transfer.fsckObjects true &&
	git -C dst.git config transfer.unpackLimit 1 &&
	test_must_fail git push dst.git HEAD
'

# Normally our packs contain commits followed by trees followed by blobs. This
# reverses the order, which requires backtracking to find the context of a
# blob. We'll start with a fresh gitmodules-only tree to make it simpler.
test_expect_success 'create oddly ordered pack' '
	git checkout --orphan odd &&
	git rm -rf --cached . &&
	git add .gitmodules &&
	git commit -m odd &&
	{
		pack_header 3 &&
		pack_obj $(git rev-parse HEAD:.gitmodules) &&
		pack_obj $(git rev-parse HEAD^{tree}) &&
		pack_obj $(git rev-parse HEAD)
	} >odd.pack &&
	pack_trailer odd.pack
'

test_expect_success 'transfer.fsckObjects handles odd pack (unpack)' '
	rm -rf dst.git &&
	git init --bare dst.git &&
	test_must_fail git -C dst.git unpack-objects --strict <odd.pack
'

test_expect_success 'transfer.fsckObjects handles odd pack (index)' '
	rm -rf dst.git &&
	git init --bare dst.git &&
	test_must_fail git -C dst.git index-pack --strict --stdin <odd.pack
'

test_expect_success 'fsck detects symlinked .gitmodules file' '
	git init symlink &&
	(
		cd symlink &&

		# Make the tree directly to avoid index restrictions.
		#
		# Because symlinks store the target as a blob, choose
		# a pathname that could be parsed as a .gitmodules file
		# to trick naive non-symlink-aware checking.
		tricky="[foo]bar=true" &&
		content=$(git hash-object -w ../.gitmodules) &&
		target=$(printf "$tricky" | git hash-object -w --stdin) &&
		tree=$(
			{
				printf "100644 blob $content\t$tricky\n" &&
				printf "120000 blob $target\t.gitmodules\n"
			} | git mktree
		) &&
		commit=$(git commit-tree $tree) &&

		# Check not only that we fail, but that it is due to the
		# symlink detector; this grep string comes from the config
		# variable name and will not be translated.
		test_must_fail git fsck 2>output &&
		grep gitmodulesSymlink output
	)
'

test_expect_success MINGW 'prevent git~1 squatting on Windows' '
	git init squatting &&
	(
		cd squatting &&
		mkdir a &&
		touch a/..git &&
		git add a/..git &&
		test_tick &&
		git commit -m initial &&

		modules="$(test_write_lines \
			"[submodule \"b.\"]" "url = ." "path = c" \
			"[submodule \"b\"]" "url = ." "path = d\\\\a" |
			git hash-object -w --stdin)" &&
		rev="$(git rev-parse --verify HEAD)" &&
		hash="$(echo x | git hash-object -w --stdin)" &&
		git -c core.protectNTFS=false update-index --add \
			--cacheinfo 100644,$modules,.gitmodules \
			--cacheinfo 160000,$rev,c \
			--cacheinfo 160000,$rev,d\\a \
			--cacheinfo 100644,$hash,d./a/x \
			--cacheinfo 100644,$hash,d./a/..git &&
		test_tick &&
		git -c core.protectNTFS=false commit -m "module" &&
		test_must_fail git show HEAD: 2>err &&
		test_i18ngrep backslash err
	) &&
	test_must_fail git -c core.protectNTFS=false \
		clone --recurse-submodules squatting squatting-clone 2>err &&
	test_i18ngrep "directory not empty" err &&
	! grep gitdir squatting-clone/d/a/git~2
'

test_expect_success 'git dirs of sibling submodules must not be nested' '
	git init nested &&
	(
		cd nested &&
		test_commit nested &&
		cat >.gitmodules <<-EOF &&
		[submodule "hippo"]
			url = .
			path = thing1
		[submodule "hippo/hooks"]
			url = .
			path = thing2
		EOF
		git clone . thing1 &&
		git clone . thing2 &&
		git add .gitmodules thing1 thing2 &&
		test_tick &&
		git commit -m nested
	) &&
	test_must_fail git clone --recurse-submodules nested clone 2>err &&
	test_i18ngrep "is inside git dir" err
'

test_done
