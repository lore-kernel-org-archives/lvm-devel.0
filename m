From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 20 Feb 2015 09:35:17 +0100
Subject: master - tests: add system_id test
In-Reply-To: <20150219204548.20DC561169@fedorahosted.org>
References: <20150219204548.20DC561169@fedorahosted.org>
Message-ID: <54E6F1C5.9090001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.2.2015 v 21:45 David Teigland napsal(a):
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b896bf8f5a4e811578c0cb606b2ad73220f985fd
> Commit:        b896bf8f5a4e811578c0cb606b2ad73220f985fd
> Parent:        0c6faaab4321ff91672ad818c47b8120d2b14180
> Author:        David Teigland <teigland@redhat.com>
> AuthorDate:    Thu Feb 19 14:08:51 2015 -0600
> Committer:     David Teigland <teigland@redhat.com>
> CommitterDate: Thu Feb 19 14:42:39 2015 -0600
>
> tests: add system_id test
>
> ---
>   test/shell/system_id.sh |  425 +++++++++++++++++++++++++++++++++++++++++++++++
>   1 files changed, 425 insertions(+), 0 deletions(-)
>
> diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
> new file mode 100644
> index 0000000..feb66ae
> --- /dev/null
> +++ b/test/shell/system_id.sh
> @@ -0,0 +1,425 @@
> +#!/bin/sh
> +# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
> +#
> +# This copyrighted material is made available to anyone wishing to use,
> +# modify, copy, or redistribute it subject to the terms and conditions
> +# of the GNU General Public License v.2.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software Foundation,
> +# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> +
> +test_description='Test system_id'
> +
> +. lib/inittest
> +
> +# FIXME: vgs --foreign is not seeing foreign vg when lvmetad is not used
> +test -e LOCAL_LVMETAD || skip
> +
> +aux prepare_devs 1
> +
> +# create vg with system_id using each source
> +
> +## none
> +
> +SID=""
> +aux lvmconf "global/system_id_source = none"
> +vgcreate $vg1 "$dev1"
> +check vg_field $vg1 systemid $SID
> +vgremove $vg1
> +
> +## machineid
> +
> +if [ ! -e /etc/machine-id ]; then
> +  echo "49e0eef929d541a0b8b56128441b2d60" > /etc/machine-id
> +fi

Hi

Test suite may not change system settings - so we need to support alternative 
configurable location for such files - either via lvm.conf or possibly via 
envvar - but I guess lvm.conf is better fit here.

Test then uses it's own environment.

Zdenek



