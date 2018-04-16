From: Martin Wilck <mwilck@suse.com>
Date: Mon, 16 Apr 2018 20:53:39 +0200
Subject: [PATCH RESEND 0/2] LVM2: fix lvmetad udev rules for CHANGE events
Message-ID: <20180416185341.8588-1-mwilck@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(This has been sent to lvm-devel on Dec 21, 2017, and apparently got
lost. Resending).

The current logic in 69-dm-lvm-metad.rules is broken for the default
"enable-udev-systemd-background-jobs" case. Detailed information about the
problem can be found in the commit message of the 2nd patch in the set.
That patch also contains the tiny actual change of this patch set: if
systemd background jobs are active, the variables SYSTEMD_ALIAS and
SYSTEMD_WANTS are also set for CHANGE events, not only for ADD.

The reason that the patch set is quite large nonetheless is that I wanted
the comments in the rules file to match the actual behavior. Substitution
of multi-line comments is very hard, if not impossible, with the string
substitution approach in the current Makefile. That necessitates the first
patch, which introduces no functional change.

Martin Wilck (2):
  lvm2: 69-dm-lvm-metad.rules: explicit pvscan rule
  lvm2: 69-dm-lvm-metad.rules: set systemd vars on "change"

 udev/69-dm-lvm-metad.rules.in | 53 +++++++++++++++++++++++++++++++++++++++----
 udev/Makefile.in              |  9 +++++---
 2 files changed, 54 insertions(+), 8 deletions(-)

-- 
2.16.1


