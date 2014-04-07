From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 7 Apr 2014 14:04:48 +0100
Subject: master - thin: Support thin_check --clear-needs-check-flag.
In-Reply-To: <534270D1.2040609@redhat.com>
References: <20140404012333.25D0B6109F@fedorahosted.org>
	<534270D1.2040609@redhat.com>
Message-ID: <20140407130448.GA24460@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 07, 2014 at 11:33:05AM +0200, Marian Csontos wrote:
> IIUC this needs a LVM2 Bugzilla to get included in RHEL7, does not it?

There are no more builds scheduled.
This is not a release blocker.

Options are: 
1) Documentating the workaround

  - Under precisely what circumstances would a user find a 'needs check' flag needs clearing by lvm?

Answer based on text in the patch submission:
"If a thin metadata operation fails the current transaction will abort,
whereby causing potential for IO layers up the stack (e.g. filesystems)
to have data loss.  As such, set THIN_METADATA_NEEDS_CHECK_FLAG in the
thin metadata's superblock which forces the user to:
1) verify the thin metadata is consistent (e.g. use thin_check, etc)
2) verify the thin data is consistent (e.g. use fsck)"

  - How do they clear it? 

Answer by setting global/thin_check_options to "-q --clear-needs-check-flag" in
lvm.conf.

2) A day0 update.
3) A z-stream update.

I'm leaning towards z-stream, as the change isn't needed until the user has a failure.

Alasdair


