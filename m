From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 30 Nov 2009 10:01:33 +0000
Subject: [PATCH] Optionally abort on internal errors.
In-Reply-To: <4B12DAC3.2030305@redhat.com>
References: <87ocml3zeu.fsf@twilight.int.mornfall.net.>
	<4B12DAC3.2030305@redhat.com>
Message-ID: <20091130100133.GC22702@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Nov 29, 2009 at 09:34:11PM +0100, Milan Broz wrote:
> +	if (level <= _LOG_ERR && !strncmp(format, "Internal error:",
> +					  strlen("Internal error:")))
> (why strlen? just len or better #define the string)
 
#define LOG_INTERNAL_ERR "Internal error: "

These messages may occur at any log level.
In normal circumstances not all of them prevent the program proceeding,
but all should be fatal if this option is set.

> - maybe only activate that when in debug (verbose mode)?

Too confusing.  Control via --config should be sufficient for now.
 
Alasdair


