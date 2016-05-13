From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 14 May 2016 00:44:29 +0100
Subject: LVM RAID man page (lvmraid.7)
In-Reply-To: <5ECBB141-6118-4C80-8710-7D7243CA38AB@redhat.com>
References: <5ECBB141-6118-4C80-8710-7D7243CA38AB@redhat.com>
Message-ID: <20160513234429.GA2767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 13, 2016 at 06:23:52PM -0500, Jon Brassow wrote:
> +"mirror" segment type.  (The "raid1" segment type became the default in
> +LVM version 2.02.100.)

Integration of further md raid features is under active development.

> +subLVs are normally "hidden", that is, not reported when displaying
> +logical volumes using 'lvs' without the '-a' option.

Shown as [hidden]

Explain naming conventions, suffices with examples.

Also review the mdadm man page for any topics missing and provide a 
mapping between the two sets of terminology?

Alasdair


