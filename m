From: Milan Broz <mbroz@redhat.com>
Date: Sun, 29 Nov 2009 21:34:11 +0100
Subject: [PATCH] Optionally abort on internal errors.
In-Reply-To: <87ocml3zeu.fsf@twilight.int.mornfall.net.>
References: <87ocml3zeu.fsf@twilight.int.mornfall.net.>
Message-ID: <4B12DAC3.2030305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/29/2009 08:26 PM, Petr Rockai wrote:
> a fairly straightforward patch adding a configure option that will
> abort() the process in case it encounters an internal
> error. Undocumented so far and not sure it's appropriate to expose --
> but maybe we have a policy of no undocumented options?

I like that idea, very useful for test suite.

ACK from me.

just some nitpicking changes like

+	if (level <= _LOG_ERR && !strncmp(format, "Internal error:",
+					  strlen("Internal error:")))
(why strlen? just len or better #define the string)

- should it be in log section (global?)

- maybe only activate that when in debug (verbose mode)?

Milan


