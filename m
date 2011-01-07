From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Jan 2011 14:16:23 +0000
Subject: [PATCH 7/8] Stop calling fs_unlock() and dm_udev_wait()
In-Reply-To: <82f127caaf42958f462a16c3981527b7a925a42d.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
	<82f127caaf42958f462a16c3981527b7a925a42d.1294398815.git.zkabelac@redhat.com>
Message-ID: <20110107141623.GI5910@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 07, 2011 at 12:17:35PM +0100, Zdenek Kabelac wrote:
> Stop calling fs_unlock() from lv_de/activate()
 
Ack.

> @@ -1669,9 +1663,12 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
  
> +	/* Restore fs cookie */

Restore?

If a cookie is already allocated, re-use it; otherwise create a new one?

> +	dm_tree_set_cookie(root, fs_get_cookie());

Alasdair


