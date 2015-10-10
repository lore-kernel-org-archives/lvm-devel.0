From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 10 Oct 2015 15:17:25 +0200
Subject: [PATCH] lvcreate: support --force option
In-Reply-To: <1444473552-14906-1-git-send-email-lzhong@suse.com>
References: <1444473552-14906-1-git-send-email-lzhong@suse.com>
Message-ID: <56190FE5.1030900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.10.2015 v 12:39 Lidong Zhong napsal(a):
> The option is supported in the logic of lvcreate but is omitted in
> commands.h.
>

Nope - it's not intended to be unsupported so far.

We do support --yes  to overcome prompts.

Normally --force is meant to be used on paths to proceed with
i.e. lvremove, lvconvert

Do you have any case in mind where '--force' with lvcreate would have make any 
sense ?
IMHO creating something with --force looks to me like crazy idea to start with 
- but maybe there is some use-case I'm missing ?

Zdenek


