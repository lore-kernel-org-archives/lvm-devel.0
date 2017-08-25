From: Eric Ren <zren@suse.com>
Date: Fri, 25 Aug 2017 17:44:47 +0800
Subject: 答复： Re: [PATCH 1/1] added resizing for btrfs
In-Reply-To: <9939b97d-e6ba-ceeb-0477-041a634a216d@kit.edu>
References: <20170802174235.19869-1-marcus@hostalia.de>
	<20170802174235.19869-2-marcus@hostalia.de>
	<2c307eee-72f8-7283-6bc0-f7072e652ca2@suse.com>
	<f65efe40-1f9b-dd94-5ab3-70802ebce6f1@kit.edu>
	<599F50CE020000D40009B179@prv-mh.provo.novell.com>
	<9939b97d-e6ba-ceeb-0477-041a634a216d@kit.edu>
Message-ID: <69aaad28-94d9-7fb7-b75d-d458c8d7768c@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Marcus,


On 08/24/2017 08:49 PM, Marcus M?ller wrote:
> [...snip...]
>
> I'm certainly not one to withhold a revised patch, but: If Lidong 
> Zhong (hi!) got his patch reviewed already from btrfs folks ? I might 
> personally prefer that
>
> For example, the mount point detection based on the external `findmnt` 
> program (didn't know that existed) looks more robust, and precautions 
> that I didn't take (like setting LC_ALL for calling `btrfs`) indicate 
> that the best-case modification of my patch would actually be his 
> patch. I haven't thought of it this way so far.
>
> Do you still want me to modify my patch?

I noticed that Lidong has posted his patch for you reference. So, feel 
free to take good points from his patch
into your v2 patch. Perhaps, you may give him credits by add 
"signed-off-by" in the patch header along with yours.

Thanks,
Eric


