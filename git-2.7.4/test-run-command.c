/*
 * test-run-command.c: test run command API.
 *
 * (C) 2009 Ilari Liusvaara <ilari.liusvaara@elisanet.fi>
 *
 * This code is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include "git-compat-util.h"
#include "run-command.h"
#include "argv-array.h"
#include "strbuf.h"
#include "gettext.h"
#include "parse-options.h"

static uint64_t my_random_next = 1234;

static uint64_t my_random(void)
{
	uint64_t res = my_random_next;
	my_random_next = my_random_next * 1103515245 + 12345;
	return res;
}

static int quote_stress_test(int argc, const char **argv)
{
	/*
	 * We are running a quote-stress test.
	 * spawn a subprocess that runs quote-stress with a
	 * special option that echoes back the arguments that
	 * were passed in.
	 */
	char special[] = ".?*\\^_\"'`{}()[]<>@~&+:;$%"; // \t\r\n\a";
	int i, j, k, trials = 100, skip = 0, msys2 = 0;
	struct strbuf out = STRBUF_INIT;
	struct argv_array args = ARGV_ARRAY_INIT;
	struct option options[] = {
		OPT_INTEGER('n', "trials", &trials, "Number of trials"),
		OPT_INTEGER('s', "skip", &skip, "Skip <n> trials"),
		OPT_BOOL('m', "msys2", &msys2, "Test quoting for MSYS2's sh"),
		OPT_END()
	};
	const char * const usage[] = {
		"test-run-command quote-stress-test <options>",
		NULL
	};

	argc = parse_options(argc, argv, NULL, options, usage, 0);

	setenv("MSYS_NO_PATHCONV", "1", 0);

	for (i = 0; i < trials; i++) {
		struct child_process cp = CHILD_PROCESS_INIT;
		size_t arg_count, arg_offset;
		int ret = 0;

		argv_array_clear(&args);
		if (msys2)
			argv_array_pushl(&args, "sh", "-c",
					 "printf %s\\\\0 \"$@\"", "skip", NULL);
		else
			argv_array_pushl(&args, "test-run-command",
					 "quote-echo", NULL);
		arg_offset = args.argc;

		if (argc > 0) {
			trials = 1;
			arg_count = argc;
			for (j = 0; j < arg_count; j++)
				argv_array_push(&args, argv[j]);
		} else {
			arg_count = 1 + (my_random() % 5);
			for (j = 0; j < arg_count; j++) {
				char buf[20];
				size_t min_len = 1;
				size_t arg_len = min_len +
					(my_random() % (ARRAY_SIZE(buf) - min_len));

				for (k = 0; k < arg_len; k++)
					buf[k] = special[my_random() %
						ARRAY_SIZE(special)];
				buf[arg_len] = '\0';

				argv_array_push(&args, buf);
			}
		}

		if (i < skip)
			continue;

		cp.argv = args.argv;
		cp.no_stdin = 1;
		cp.out = -1;
		if (start_command(&cp) < 0)
			return error("Failed to spawn child process");
		strbuf_reset(&out);
		if (strbuf_read(&out, cp.out, 0) < 0)
			return error("could not read output of `quote-echo`");
		if (finish_command(&cp))
			warning("something when wrong with `quote-echo`");

		for (j = 0, k = 0; j < arg_count; j++) {
			const char *arg = args.argv[j + arg_offset];

			if (strcmp(arg, out.buf + k))
				ret = error("incorrectly quoted arg: '%s', "
					    "echoed back as '%s'",
					     arg, out.buf + k);
			k += strlen(out.buf + k) + 1;
		}

		if (k != out.len)
			ret = error("got %d bytes, but consumed only %d",
				     (int)out.len, (int)k);

		if (ret) {
			fprintf(stderr, "Trial #%d failed. Arguments:\n", i);
			for (j = 0; j < arg_count; j++)
				fprintf(stderr, "arg #%d: '%s'\n",
					(int)j, args.argv[j + arg_offset]);

			strbuf_release(&out);
			argv_array_clear(&args);

			return ret;
		}

		if (i && (i % 100) == 0)
			fprintf(stderr, "Trials completed: %d\n", (int)i);
	}

	strbuf_release(&out);
	argv_array_clear(&args);

	return 0;
}

static int quote_echo(int argc, const char **argv)
{
	while (argc > 1) {
		fwrite(argv[1], strlen(argv[1]), 1, stdout);
		fputc('\0', stdout);
		argv++;
		argc--;
	}

	return 0;
}

int main(int argc, char **argv)
{
	struct child_process proc = CHILD_PROCESS_INIT;

	if (argc >= 2 && !strcmp(argv[1], "quote-stress-test"))
		return !!quote_stress_test(argc - 1, (const char **)argv + 1);

	if (argc >= 2 && !strcmp(argv[1], "quote-echo"))
		return !!quote_echo(argc - 1, (const char **)argv + 1);

	if (argc < 3)
		return 1;
	proc.argv = (const char **)argv+2;

	if (!strcmp(argv[1], "start-command-ENOENT")) {
		if (start_command(&proc) < 0 && errno == ENOENT)
			return 0;
		fprintf(stderr, "FAIL %s\n", argv[1]);
		return 1;
	}
	if (!strcmp(argv[1], "run-command"))
		exit(run_command(&proc));

	fprintf(stderr, "check usage\n");
	return 1;
}
