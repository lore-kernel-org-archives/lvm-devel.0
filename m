From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 5 Oct 2009 18:13:03 +0100
Subject: [PATCH 0/10]: Add implicit pvcreate support in vgcreate / vgextend.
In-Reply-To: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20091005171303.GA15687@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Oct 04, 2009 at 07:11:37PM -0400, Dave Wysochanski wrote:
> This patch set is a rebase and rewrite of the earlier implicit pvcreate
> patchset.  These patches should address most, if not all, feedback to date,
> and include updated tests.  Once these patches are in, a user should no
> longer need pvcreate, except in rare recovery scenarios (usage of 
> --uuid, --restorefile, and --physicalvolumesize are not supported with
> vgcreate and vgextend).
 
Ack to the complete set.

Alasdair


