From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 22 Sep 2010 15:20:30 +0200
Subject: [PATCH 17/19] Rename internal vg_get_property to more generic lvm_get_property.
In-Reply-To: <1285001396.5111.8.camel@f12-work>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>	<1284564971-26060-18-git-send-email-dwysocha@redhat.com>	<4C91D82D.2080302@redhat.com>
	<4C91DBDF.7010508@redhat.com> <1285001396.5111.8.camel@f12-work>
Message-ID: <4C9A029E.5080906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.9.2010 18:49, Dave Wysochanski napsal(a):
> On Thu, 2010-09-16 at 10:57 +0200, Zdenek Kabelac wrote:
>> Dne 16.9.2010 10:41, Zdenek Kabelac napsal(a):
>>> Dne 15.9.2010 17:36, Dave Wysochanski napsal(a):
>>>>  lib/report/properties.c |    4 ++--
>>>>  lib/report/properties.h |    2 +-
>>>>  liblvm/lvm_vg.c         |    2 +-
>>>>  3 files changed, 4 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/lib/report/properties.c b/lib/report/properties.c
>>>> index 0b80593..95da8ab 100644
>>>> --- a/lib/report/properties.c
>>>> +++ b/lib/report/properties.c
> +
> +int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)

This function should be able to operate with const* vg - or do we need to
modify vg with some get functionality ?

> +int pv_get_property(struct physical_volume *pv, struct lvm_property_type *prop)

const* pv


Zdenek


