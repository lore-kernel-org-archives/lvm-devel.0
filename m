From: Bartłomiej Błachut <bartlomiejblachut@gmail.com>
Date: Wed, 28 Sep 2022 17:16:41 +0200
Subject: How to change default system dir
Message-ID: <CAPA01J3mh6G22h1938GYvPAZunah2Nv+HGikjBef05RBNHBj3w@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,
I have a question for you, because what I need is to change in my
ubuntu(22.04) the localisation of default-system-dir from /etc/lvm to a
place where I have write access e.g. /home/my_user/new_lvm_dir. I've tried
so far to provide to ./configure option
--with-default-system-dir=/home/my_user/new_lvm_dir or later I replace
everywhere in code pattern /etc/lvm to /home/my_user/new_lvm_dir but
without any success. Are you able to give me any idea how I can do it ?

I tried it on main/stable branches git://sourceware.org/git/lvm2.git

Cheers,
Bartek
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220928/63aa549f/attachment-0001.htm>
