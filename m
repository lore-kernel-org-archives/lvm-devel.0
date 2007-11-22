From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 22 Nov 2007 02:01:18 +0000
Subject: [PATCH mirror 0/13] Add/collapse temporary mirror
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <20071122020118.GR22843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 21, 2007 at 08:45:24PM -0500, Jun'ichi Nomura wrote:
> because I vaguely remember that naming suffixes like "_mimage_<n>"

dm_snprintf(img_name, len, "%s_mimage_%%d", lv->name)

Gah - how did that underscore sneak in front of the name:-(
Oh well, we're stuck with it for now.

Reserved names are controlled by:
  apply_lvname_restrictions()

and should be consistent: all 'mimage' LVs should be structured
the same way.  If not, it may require a different name.

Alasdair
-- 
agk at redhat.com


