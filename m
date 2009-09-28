From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Sep 2009 20:44:41 +0100
Subject: [PATCH 2/3] Fix possible lost of temporary devices in pvmove.
In-Reply-To: <4AB254F7.5050509@redhat.com>
References: <4AB254F7.5050509@redhat.com>
Message-ID: <20090928194440.GL5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Sep 17, 2009 at 05:25:43PM +0200, Milan Broz wrote:
>  - if pvmove fails, try to sleep some time and retry. Usually device is locked
>  by scan from wrong udev rule and remapping to error target causes all scanning
>  programs to quickly fail.

I'd rather see the real problem addressed: people fixing misbehaving udev
rules.  There should be no need for workarounds like this in lvm2, which would
only perpetuate the problem.  Presumably the problem will disappear anyway
when the udev integration work is activated.

Alasdair


