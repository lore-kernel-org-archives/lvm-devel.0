From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Thu, 31 Jan 2013 11:50:51 +0530
Subject: [RFC/PATCH] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <1358925908-32347-2-git-send-email-mohan@in.ibm.com>
References: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
	<1358925908-32347-2-git-send-email-mohan@in.ibm.com>
Message-ID: <87vcad27r0.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

"M. Mohan Kumar" <mohan@in.ibm.com> writes:

> +lv_t lvm_lv_thinpool(const vg_t vg, const char *pool_name, uint64_t size);
> +

We need to specify 'low_water_mark' when creating a thin pool. Otherwise
a thin pool is created with 0 as low_water_mark and it will never
trigger a dm event so that an userspace daemon can do the resizing of
pool.

I am looking at how to pass this low water mark data to dm create. So
please do not merge this patch till we have capability to mention
low_water_mark argument for thin pool creation.
 


