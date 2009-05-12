From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 May 2009 18:21:09 -0400
Subject: Remove NONBLOCK flag from higher-level tools.
Message-ID: <1242166871-25734-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following two patches are two approaches to solving the
same problem: remove the NONBLOCK flag from the higher-level
vg_read() function.  This simplifies the API for the user.

Both patches take a similar approach - enforce a policy that
the second VG lock implicitly sets the NONBLOCK flag.  One
patch places the code inside lock_vol() and should apply
cleanly on upstream LVM.  The other patch places the code
inside the new vg_read() interface and should apply cleanly
on top of Petr's vg_read() patches submitted on May 3.



