From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Thu, 29 Sep 2022 12:58:40 +0200
Subject: How to change default system dir
In-Reply-To: <CAPA01J3mh6G22h1938GYvPAZunah2Nv+HGikjBef05RBNHBj3w@mail.gmail.com>
References: <CAPA01J3mh6G22h1938GYvPAZunah2Nv+HGikjBef05RBNHBj3w@mail.gmail.com>
Message-ID: <17734cfc-cef2-3f6b-1426-ea8100bdd667@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28. 09. 22 v 17:16 Bart?omiej B?achut napsal(a):
> Hi,
> I have a question?for you, because what I need is to change in my 
> ubuntu(22.04) the localisation of default-system-dir from /etc/lvm to a place 
> where I have write access e.g. /home/my_user/new_lvm_dir. I've tried so far to 
> provide to ./configure option 
> --with-default-system-dir=/home/my_user/new_lvm_dir or later I replace 
> everywhere in code pattern /etc/lvm to /home/my_user/new_lvm_dir but without 
> any success. Are you able to give me any idea how I can do it ?
> 
> I tried it on main/stable branches?git://sourceware.org/git/lvm2.git 
> <http://sourceware.org/git/lvm2.git>
> 

Hi


lvm2 basically always require a 'root' access for any 'real usable' lvm2 
command - so saying you don't have write access to /etc  looks very strange to 
start with.

We have also configure option  --with-confdir=[/etc]
but I still think you should start with explaining what are you actually 
trying to do - as maybe there is some design issue??


Regards

Zdenek

