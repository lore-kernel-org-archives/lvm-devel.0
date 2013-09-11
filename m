From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Wed, 11 Sep 2013 09:37:33 +0200
Subject: master - RAID: Make RAID single-machine-exclusive capable in a cluster
In-Reply-To: <20130910213404.7EAD36104E@fedorahosted.org>
References: <20130910213404.7EAD36104E@fedorahosted.org>
Message-ID: <52301DBD.3080907@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.9.2013 23:34, Jonathan Brassow napsal(a):
>   	dm_list_iterate_items(lvl, &removal_list) {
> -		if (!resume_lv(lv->vg->cmd, lvl->lv)) {
> +		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {


I guess in places like this we should use using plain exclusive or plain local.

It's supposed to be activated according to tags - so it should be possible
to hand over activation to different node in cluster.

For clearing of devices on the other hand we need to use  'local' activation
since we need to access and clear device on the local node ignoring any tags.

Also note - we still have a minor problem with deactivation after clearing,
where we do not have synchronization point (until we switch to monitoring),
so we may occasionally report deactivation retry error message (so for 
non-clustered VG) it's better to keep device active if the parent node is 
going to be activated (since we have no problems with LV locks - it's not a 
big issue)

Zdenek


