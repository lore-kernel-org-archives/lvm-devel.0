From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 19 Apr 2010 18:06:28 +0100
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c
In-Reply-To: <4BCC77EC.30005@redhat.com>
References: <20100419152225.3141.qmail@sourceware.org>
	<4BCC77EC.30005@redhat.com>
Message-ID: <20100419170628.GE4828@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 19, 2010 at 05:34:04PM +0200, Zdenek Kabelac wrote:
> Either we should return   const char*  return vg->name;

But then we have to guarantee that vg->name remains const - which we are
unable to do.  (We can't impose limits on vgrename.)

Alasdair


