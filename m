From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 24 May 2017 10:59:30 +0200
Subject: [PATCH] clvmd: try to refresh device cache on the first failure
In-Reply-To: <20170524084519.12204-1-zren@suse.com>
References: <20170524084519.12204-1-zren@suse.com>
Message-ID: <dafc93b4-0f3b-57a5-9055-4c9409d8fcf0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 24.5.2017 v 10:45 Eric Ren napsal(a):
> Sometimes, the device cache in clvmd could be out of date.
> "clvmd -R" is invented for this issue. However, to run
> "clvmd -R" manually is not convenient, because it's hard
> to predict when device change would happen.
> 

Hi

Looking at the patch header - it doesn't really look like solution for 
clustered problem clvmd cannot be resolve out-of-sync trouble of your cluster 
- it'd be likely masking serious problems elsewhere.

So could you please start with regular trouble report first - i.e. what do you 
mean by 'sometimes' ???

Regard

Zdene


