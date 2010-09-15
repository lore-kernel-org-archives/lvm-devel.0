From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:35:52 -0400
Subject: [PATCH 00/19] Add lvm vg and pv properties for lvm2app.
Message-ID: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a repost and add onto the previous patchset
posted to lvm-devel on 9/9/2010.  It continues that patchset
and adds pv properties and addresses comments made on the vg
patchset.

Notable changes:
1. Simplified logic to create 'attr' strings based on review comment
2. Rework GET_*_PROPERTY_FN macro to allow for pv, vg, and lv
3. Renamed internal function vg_get_property to lvm_get_property
4. Add a lvm_pv_get_property function similar to the vg one
5. Various refactorings related to pv properties.

All vg and pv properties may now be queried with this patchset.
I will now move on to lv properties.


