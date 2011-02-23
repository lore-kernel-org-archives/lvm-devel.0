From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 23 Feb 2011 15:14:40 +0100
Subject: [PATCH 3/3] Destroy 'fic' memory in error path
In-Reply-To: <2a970eeba07b551a68f7abab7bbf2acd2e4c61c8.1298466569.git.zkabelac@redhat.com>
References: <cover.1298466569.git.zkabelac@redhat.com>
	<2a970eeba07b551a68f7abab7bbf2acd2e4c61c8.1298466569.git.zkabelac@redhat.com>
Message-ID: <4D651650.3030606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/23/2011 02:52 PM +0100, Zdenek Kabelac wrote:
> +			fid->fmt->ops->destroy_instance(fid);

...and I'll send a patch that adds the content to destroy_instance
since it's pure void now :)

Also, we need to add destroy_instance everywhere where necessary
throughout the code. We haven't used this call before because we
relied on automatic mempool deallocation mostly.

Peter


