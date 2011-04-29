From: Milan Broz <mbroz@redhat.com>
Date: Fri, 29 Apr 2011 13:15:47 +0200
Subject: [PATCH 5/5] Set our own in/out buffers
In-Reply-To: <0e34a9ec4665a437ec685e7845099d5080a2f659.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
	<0e34a9ec4665a437ec685e7845099d5080a2f659.1303215346.git.zkabelac@redhat.com>
Message-ID: <4DBA9DE3.9020506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/19/2011 02:55 PM, Zdenek Kabelac wrote:
> Memory lock from critical_section is now being kept over the critical
> section - mallopt() should ensure, that mmap is not used for allocation,
> and we preallocate some memory to be able to satisfy some small
> alloc request. However when glibc needs buffers for line buffering of
> input and output buffers - it allocates these buffers in such way it
> adds memory page for each such buffer and size of unlock memory check will
> mismatch by 1 or 2 pages.

So this will fix that famous 1 page difference in memory lock/unlock.

> +	/* Set in/out stream buffering before glibc */
> +	if (set_buffering) {
> +		/* Allocate 2 buffers */
> +		if (!(cmd->linebuffer = dm_malloc(2 * linebuffer_size))) {
> +			log_error("Failed to allocate line buffer.");
> +			goto out;
> +		}
> +		if ((setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size) ||
> +		     setvbuf(stdout, cmd->linebuffer + linebuffer_size,

IMHO I would better allocate two separate buffers here, if it uses some
stack markers to detect overflow, it will be effectively switched off
for stdin buffer.

(But it is internal glibc thing.)

> +	if (cmd->linebuffer) {
> +		/* Reset stream buffering to defaults */
> +		setlinebuf(stdin);

btw this requires _BSD_SOURCE, isn't better use
setvbuf(stream, (char *) NULL, _IOLBF, 0); ? (see man page)

> +		fflush(stdout);

(I guess flush is implicit but it is not documented so better to be safe.)


ACK, I think we should squeeze it in current release ;-)

Milan

