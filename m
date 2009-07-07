From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Jul 2009 22:46:25 +0100
Subject: [PATCH 7/7] Add lvm_vg_create() - vg constructor API for new volume groups.
In-Reply-To: <1246953008-27609-8-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-4-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-5-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-6-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-7-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-8-git-send-email-dwysocha@redhat.com>
Message-ID: <20090707214625.GJ11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jul 07, 2009 at 03:50:08AM -0400, Dave Wysochanski wrote:
> 1. The VG_ORPHAN lock needs some thought.  

Outside the scope of the new library interface: it will not need to
deal with orphans, as discussed at LinuxTag.

Alasdair


