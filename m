From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 13 Aug 2010 18:33:27 +0100
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in
In-Reply-To: <20100812134120.6324.qmail@sourceware.org>
References: <20100812134120.6324.qmail@sourceware.org>
Message-ID: <20100813173327.GF26032@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 12, 2010 at 01:41:20PM -0000, prajnoha at sourceware.org wrote:
> 	ignored. However, initrd is not updated automatically while updating the
> 	libdevmapper/udev rules in the system and so we end up with the rules not

We discussed this some time ago and had to rule it out: there is no reasonable
existing mechanism for triggering an update to all the still-usable initrds
when the lvm2 package is updated.  People need to be able to switch between
installed kernels without changing userspace.  (LVM1 used to suffer from that
problem.)

Alasdair


