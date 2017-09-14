From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Sep 2017 13:24:54 +0200
Subject: [Patch review 0/1] introduce lvm forcevg option to forcibly deactivate the whole vg
In-Reply-To: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
References: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
Message-ID: <f74eba33-de77-2b26-31d1-5c103f4ec261@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.9.2017 v 09:37 Zhang Huan napsal(a):
> Hi all,
> 
> commit 92ded9af9809dd0f4233bacaafab3e7942a6afff
> Author: Huan Zhang <zhanghuan@chinac.com>
> Date:   Thu Sep 14 15:25:05 2017 +0800
> 
>      introduce lvm forcevg option to forcibly deactivate the whole vg
>      

Hi

Coincidentally - I've just opened this BZ today:

https://bugzilla.redhat.com/show_bug.cgi?id=1491609

Mostly likely this BZ can be extended to also support forcible table
remove for  'vg/lvchange' command.


The solution presented in this patch can interfere with lvm2 commands so I'd 
be worrying about data correctness.

Regards

Zdenek


