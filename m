From: Eric Ren <renzhengeek@gmail.com>
Date: Sat, 13 Apr 2019 10:08:10 +0800
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <a719d149-c9af-98e3-8983-5418584b11b0@redhat.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
	<CAKM4Aexiy-iXuNs6Nn-JudytKQRizovjg_3TVL0_xn_7+e3wXg@mail.gmail.com>
	<CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
	<CAKM4AewQpxTmRZ=GNqCaEb0yL=5ukVUNrhWJ-bFnXeaFoiJh4Q@mail.gmail.com>
	<a719d149-c9af-98e3-8983-5418584b11b0@redhat.com>
Message-ID: <CAKM4AezfHJ1V+UvDKX_9=VPPdHK9btGGK9AFJXihwY3D2s99fw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

> Hmm would it be possible that associated thin pool would be in some erroneous
> condition - i.e. out-of-space - or processing some resize ?

The testing model is:

create/mount/"do IO" (on) thin LV; and then umount/delete thin LV.

doing this work flow in parallel.

> This likely could result into some significant processing delay ?
>
> Since you are using very ancient lvm2  (2.02.130) we have heavily improved
> logic for such pools over the time...

Hah, I think I've mentioned this issue can be reproduced on centos 7.6
(2.02.180).

Regards,
Eric


