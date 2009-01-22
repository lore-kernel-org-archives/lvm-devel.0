From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:09:56 +0100
Subject: [PATCH] Another take on vg_read.
Message-ID: <1232619010-4858-1-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hi,

I have done some more work on this series. I am resending everything, to avoid
sequencing problems like I introduced last time with a partial send.

Anyway, some news:
- the vg_check_status CLUSTERED fallthrough is fixed to return immediately
- cluster locking is now properly enforced by vg_read/vg_read_for_update
- process_each_pv is also ported over to new vg_read
- vg_read_internal is now private in metadata.c (static _vg_read_internal)
(plus, all patches should apply cleanly on top of today's CVS)

Hopefully, this moves things forward a little.

Yours,
   Petr.


