From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Jun 2015 16:10:55 +0100
Subject: udev cookie on DM_DEVICE_RELOAD
In-Reply-To: <55915DB3.7060802@redhat.com>
References: <55914C1C.6050309@suse.de> <20150629140220.GA1604@redhat.com>
	<55915B15.708@redhat.com> <55915CB6.9070407@suse.de>
	<55915DB3.7060802@redhat.com>
Message-ID: <20150629151055.GC14262@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jun 29, 2015 at 05:01:07PM +0200, Peter Rajnoha wrote:
> suspend -> reload -> dm_task_set_cookie -> resume -> dm_udev_wait

Or rather, 
  set cookie -> reload -> suspend -> resume -> wait

Reload can fail and allocates kernel resources, and suspend ties up kernel
resources so as little as possible should be done between the suspend
and the resume.

Alasdair


