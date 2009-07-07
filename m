From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Jul 2009 22:25:00 +0100
Subject: [PATCH 0/7]: Implement lvm_vg_create() and 4 required vg_set*() APIs
In-Reply-To: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20090707212500.GH11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jul 07, 2009 at 03:50:01AM -0400, Dave Wysochanski wrote:
> The following 7 patches implement the beginning of lvm_vg_create() liblvm API.
> This API will create a VG with default parameters and return a vg_t.  Later,
> if any parameters of the VG need set, they are done with a separate 'set' call.

The distinction we made at LinuxTag was between parameters that would normally
need to be set (like the name of the VG) and parameters that normally do not need
to be (like max_lv).  (This is judged from the perspective of a typical library
user - not necessarily the lvm2 tools themselves.)

Alasdair


