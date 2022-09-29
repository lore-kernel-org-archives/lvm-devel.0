From: Roger Heflin <rogerheflin@gmail.com>
Date: Thu, 29 Sep 2022 09:37:04 -0500
Subject: [linux-lvm] How to change default system dir
In-Reply-To: <17734cfc-cef2-3f6b-1426-ea8100bdd667@gmail.com>
References: <CAPA01J3mh6G22h1938GYvPAZunah2Nv+HGikjBef05RBNHBj3w@mail.gmail.com>
 <17734cfc-cef2-3f6b-1426-ea8100bdd667@gmail.com>
Message-ID: <CAAMCDee_xu--G63yWDS7KSd85+RfWqcXv6QH8yA-CgCFFLeLSA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Assuming you are write protecting /etc for a reason, simply mv
everything in /etc/lvm to your new location and replace the lvm dir
with a lvm symbolic link to your location.

In the far past when booting with RO devices I had lots of links in
/etc/ pointing to files that were not on the read-only and/or
writable-but-lost-on-boot(overlay) device.

On Thu, Sep 29, 2022 at 5:58 AM Zdenek Kabelac <zdenek.kabelac@gmail.com> wrote:
>
> Dne 28. 09. 22 v 17:16 Bart?omiej B?achut napsal(a):
> > Hi,
> > I have a question for you, because what I need is to change in my
> > ubuntu(22.04) the localisation of default-system-dir from /etc/lvm to a place
> > where I have write access e.g. /home/my_user/new_lvm_dir. I've tried so far to
> > provide to ./configure option
> > --with-default-system-dir=/home/my_user/new_lvm_dir or later I replace
> > everywhere in code pattern /etc/lvm to /home/my_user/new_lvm_dir but without
> > any success. Are you able to give me any idea how I can do it ?
> >
> > I tried it on main/stable branches git://sourceware.org/git/lvm2.git
> > <http://sourceware.org/git/lvm2.git>
> >
>
> Hi
>
>
> lvm2 basically always require a 'root' access for any 'real usable' lvm2
> command - so saying you don't have write access to /etc  looks very strange to
> start with.
>
> We have also configure option  --with-confdir=[/etc]
> but I still think you should start with explaining what are you actually
> trying to do - as maybe there is some design issue??
>
>
> Regards
>
> Zdenek
>
> _______________________________________________
> linux-lvm mailing list
> linux-lvm at redhat.com
> https://listman.redhat.com/mailman/listinfo/linux-lvm
> read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO/

