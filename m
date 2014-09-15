From: Brassow Jonathan <jbrassow@redhat.com>
Date: Mon, 15 Sep 2014 16:10:25 -0500
Subject: [PATCH 1/1] cmirrord:fix endian issue on s390
In-Reply-To: <1409891564-24053-1-git-send-email-lwang@suse.com>
References: <1409891564-24053-1-git-send-email-lwang@suse.com>
Message-ID: <F47F57D8-3C13-4A18-BDB8-B82934A635EE@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

committed.  I chose the author to be the person who posted the patch.

 brassow

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=829e5a40373a2ef1721dc9210350c86c4b9d70f7
Commit:        829e5a40373a2ef1721dc9210350c86c4b9d70f7
Parent:        e9216eedfe8189947c506041d8fc9e879fac6d58
Author:        Liuhua Wang <lwang@suse.com>
AuthorDate:    Sat Sep 13 02:08:28 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Sep 15 16:08:35 2014 -0500


On Sep 4, 2014, at 11:32 PM, Liuhua Wang wrote:

>        Cmirrord has endian bugs, which cause failure to lvcreate a mirrored lv on s390.
>        - data_size is uint32, should not use xlate64 to convert, which will cause data_size 0
>          after xlate.
>        - request_type and data_size still used by local(v5_data_switch), should convert later.
>          if request_type xlate too early, it will cause request_type judge error;
>          if data_size xlate too early, it will cause coredump in case DM_ULOG_CLEAR_REGION.
>        - when receiving package in clog_request_from_network. vp[0] will always be little endian.
>          we could use xlate64(vp[0]) == vp[0] to decide if the local node is little endian or not.
> 
> Signed-off-by: Lidong Zhong<lzhong@suse.com> & Liuhua Wang <lwang@suse.com> 
> 
> ---
> daemons/cmirrord/compat.c | 9 +++++----
> 1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/daemons/cmirrord/compat.c b/daemons/cmirrord/compat.c
> index 3f7a9b5..4955f50 100644
> --- a/daemons/cmirrord/compat.c
> +++ b/daemons/cmirrord/compat.c
> @@ -126,13 +126,14 @@ static int v5_endian_to_network(struct clog_request *rq)
> 
> 	u_rq->error = xlate32(u_rq->error);
> 	u_rq->seq = xlate32(u_rq->seq);
> -	u_rq->request_type = xlate32(u_rq->request_type);
> -	u_rq->data_size = xlate64(u_rq->data_size);
> 
> 	rq->originator = xlate32(rq->originator);
> 
> 	v5_data_endian_switch(rq, 1);
> 
> +	u_rq->request_type = xlate32(u_rq->request_type);
> +	u_rq->data_size = xlate32(u_rq->data_size);
> +
> 	return size;
> }
> 
> @@ -167,7 +168,7 @@ static int v5_endian_from_network(struct clog_request *rq)
> 	u_rq->error = xlate32(u_rq->error);
> 	u_rq->seq = xlate32(u_rq->seq);
> 	u_rq->request_type = xlate32(u_rq->request_type);
> -	u_rq->data_size = xlate64(u_rq->data_size);
> +	u_rq->data_size = xlate32(u_rq->data_size);
> 
> 	rq->originator = xlate32(rq->originator);
> 
> @@ -187,7 +188,7 @@ int clog_request_from_network(void *data, size_t data_len)
> 
> 	switch (version) {
> 	case 5: /* Upstream */
> -		if (version == unconverted_version)
> +		if (version == vp[0])
> 			return 0;
> 		break;
> 	case 4: /* RHEL 5.[45] */
> -- 
> 1.9.0
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



