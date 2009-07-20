From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 19 Jul 2009 21:53:58 -0400
Subject: [PATCH] liblvm install environment
In-Reply-To: <1247845102-8166-1-git-send-email-twoerner@redhat.com>
References: <1247845102-8166-1-git-send-email-twoerner@redhat.com>
Message-ID: <1248054838.2425.13.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ok, if we are moving away from "liblvm2app" we should be consistent in
this patch.  Our options seem to be:
1) liblvm2
2) liblvm2app
3) liblvm2api

I would vote for #1, #2, and #3 in that order.  If we really want to
leave open the door for other lvm libraries in the future, then perhaps
we need another suffix such as #2 or #3.

As has been stated on IRC, if we want to support both lvm1 and lvm2
libraries on the same machine then we cannot simply reuse "liblvm".


