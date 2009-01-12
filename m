From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 19:54:56 +0100
Subject: LVM2/test Makefile.in test-utils.sh not.c
In-Reply-To: <20090112184545.13175.qmail@sourceware.org>
	(mornfall@sourceware.org's message of "12 Jan 2009 18:45:45 -0000")
References: <20090112184545.13175.qmail@sourceware.org>
Message-ID: <87bpuc4anz.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Err.

mornfall at sourceware.org writes:
> +	pid = fork();
> +	if (pid == -1) {
> +		fprintf(stderr, "Could not fork\n");
> +		return FAILURE;
> +	} else if (pid == 0) { 	/* child */
> +		execvp(argv[1], &argv[1]);
> +		/* should not be accessible */
> +		return FAILURE;
This should probably be return SUCCESS or abort() I guess. This will turn
command not found and other unexpected failures to overall not failures (these
are treated as successes, thanks to the parent's reinterpretation of exit
code). (This still ain't a regression, I believe, though.) Opinions?

> +	} else {		/* parent */
> +		waitpid(pid, &status, 0);
> +		if (!WIFEXITED(status)) {
> +			/* did not exit correctly */
> +			return FAILURE;
> +		}
> +		/* return the opposite */
> +		return !WEXITSTATUS(status);
> +	}
> +	/* not accessible */
> +	return FAILURE;

Yours,
   Petr.

--
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


