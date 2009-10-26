From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Oct 2009 11:59:25 +0000
Subject: [PATCH] Update lvcreate/lvconvert man pages to explain PhysicalVolume parameter.
In-Reply-To: <1256525302-5189-1-git-send-email-dwysocha@redhat.com>
References: <1256525302-5189-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20091026115925.GC25303@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ack.

> +If the conversion requires allocation of physical extents (for
> +example, when converting from linear to mirror) and you specify
> +one or more PhysicalVolumes

(optionally with ranges of physical extents)

> , allocation of physical extents will
> +be restricted to these volumes.  

allocation will be restricted to these physical extents.

Alasdair


