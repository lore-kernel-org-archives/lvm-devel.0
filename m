From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 May 2014 17:45:39 +0200
Subject: master - activation: Remove empty DM device when table fails to load.
In-Reply-To: <20140528151722.E009E60E66@fedorahosted.org>
References: <20140528151722.E009E60E66@fedorahosted.org>
Message-ID: <538604A3.3030005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28.5.2014 17:17, Jonathan Brassow napsal(a):
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=442820aae3648e1846417d1248fa36030eba4bd8
> Commit:        442820aae3648e1846417d1248fa36030eba4bd8
> Parent:        8212dac849e5a820c579c06a1b2805e7934a8d8b
> Author:        Jonathan Brassow <jbrassow@redhat.com>
> AuthorDate:    Wed May 28 10:17:15 2014 -0500
> Committer:     Jonathan Brassow <jbrassow@redhat.com>
> CommitterDate: Wed May 28 10:17:15 2014 -0500
>
> activation:  Remove empty DM device when table fails to load.
>
> As part of better error handling, remove DM devices that have been
> sucessfully created but failed to load a table.  This can happen
> when pvmove'ing in a cluster and the cluster mirror daemon is not
> running on a remote node - the mapping table failing to load as a
> result.  In this case, any revert would work on other nodes running
> cmirrord because the DM devices on those nodes did succeed in loading.
> However, because no table was able to load on the non-cmirrord nodes,
> there is no table present that points to what needs to be reverted.
> This causes the empty DM device to remain on the system without being
> present in any LVM representation.
>
> This patch should only be considered a partial fix to the overall
> problem.  This is because only the device which failed to load a
> table is removed.  Any LVs that may have been loaded as requirements
> to the DM device that failed to load may be left in place.  Complete
> clean-up will require tracking those devices which have been created
> as dependencies and removing them along with the device that failed
> to load a table.
> ---
>   libdm/libdm-deptree.c |   59 ++++++++++++++++++++++++++++++++++++++++++++-----
>   1 files changed, 53 insertions(+), 6 deletions(-)
>
> diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
> index 0a53755..f34c40f 100644
> --- a/libdm/libdm-deptree.c
> +++ b/libdm/libdm-deptree.c
> @@ -1920,15 +1920,50 @@ static int _create_node(struct dm_tree_node *dnode)
>   	if (!dm_task_no_open_count(dmt))
>   		log_error("Failed to disable open_count");
>
> -	if ((r = dm_task_run(dmt)))
> -		r = dm_task_get_info(dmt, &dnode->info);
> -
> +	if ((r = dm_task_run(dmt))) {
> +		if (!(r = dm_task_get_info(dmt, &dnode->info)))
> +			/*

This is adding just another 'ioctl' on the path - IMHO this should be
removed.


Zdenek


