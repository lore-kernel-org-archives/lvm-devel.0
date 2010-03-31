From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 31 Mar 2010 15:26:22 +0100
Subject: [PATCH] Always use blocking lock for VGs and orphan locks.
In-Reply-To: <1270044308-30885-1-git-send-email-mbroz@redhat.com>
References: <1270044308-30885-1-git-send-email-mbroz@redhat.com>
Message-ID: <20100331142620.GS11377@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 31, 2010 at 04:05:08PM +0200, Milan Broz wrote:
> Because we have now strong rule for lock ordering:
>  - VG locks must be taken in alphabetical order
>  - ORPHAN locks must be the last
> vgs_locked() is now not needed.
> This fixes problem with orphan locking, e.g.
> vgremove VG1    |    vgremove VG2
> lock(VG1)       |    lock(VG2)
> lock(ORPHAN)    |    lock(ORPHAN) -> fail, non-blocking
> https://bugzilla.redhat.com/show_bug.cgi?id=578413
 
Ack.

Alasdair


