From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 17 Mar 2010 03:30:41 -0400 (EDT)
Subject: lv-shared
In-Reply-To: <20100315202843.GA1034@redhat.com>
References: <Pine.LNX.4.64.1003151453350.4733@hs20-bc2-1.build.redhat.com>
	<20100315192925.GA29389@redhat.com> <20100315202843.GA1034@redhat.com>
Message-ID: <Pine.LNX.4.64.1003170330001.9115@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Mon, 15 Mar 2010, Mike Snitzer wrote:

> On Mon, Mar 15 2010 at  3:29pm -0400,
> Mike Snitzer <snitzer@redhat.com> wrote:
> 
> > On Mon, Mar 15 2010 at  3:00pm -0400,
> > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > 
> > > Also, your changes to 2.02.62 broke shared store resizing.
> > > lvresize -L 132M vgs/lv-shared no longer works
> > 
> > OK, I can have a look but some of my changes also made it so that
> > info-by-uuid based multisnapshot cleanup actually works (needed for lvm2
> > >= 2.02.62).
> 
> I cannot reproduce this:
> 
> # lvcreate -L 1G --sharedstore mikulas -s test/testlv1
>   Logical volume "testlv1-shared" created
> 
> # lvs -a
>   LV               VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
>   testlv1          test owi-a- 4.00g                                       
>   [testlv1-shared] test swi--- 1.00g testlv1   0.00                        
> 
> # lvcreate -s -n testlv1_snap test/testlv1
>   Logical volume "testlv1_snap" created
> 
> # lvresize -L 1.5G test/testlv1-shared
>   Extending logical volume testlv1-shared to 1.50 GiB
>   Logical volume testlv1-shared successfully resized
> 
> # lvs -a
>   LV               VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
>   testlv1          test owi-a- 4.00g                                       
>   [testlv1-shared] test swi--- 1.50g testlv1   0.00                        
>   testlv1_snap     test swi-a- 4.00g testlv1                               

Now I can't reproduce it too with the same code, so I don't know what 
happened :-(

Mikulas


