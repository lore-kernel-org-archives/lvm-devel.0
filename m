From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 19 Apr 2010 19:47:57 +0100
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c
In-Reply-To: <4BCCA318.6070803@redhat.com>
References: <20100419152225.3141.qmail@sourceware.org>
	<4BCC77EC.30005@redhat.com>
	<20100419170628.GE4828@agk-dp.fab.redhat.com>
	<4BCCA318.6070803@redhat.com>
Message-ID: <20100419184757.GF4828@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 19, 2010 at 08:38:16PM +0200, Zdenek Kabelac wrote:
> wouldn't expect any *_get_* function could ever change it

Yes it could - the vgrename might have been run on a different machine in the
cluster.

Alasdair


