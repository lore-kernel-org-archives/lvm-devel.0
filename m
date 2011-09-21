From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Sep 2011 15:41:41 +0200
Subject: [PATCH 1/2] Clvmd fix restart
In-Reply-To: <498932ea49b0379d95cf520090fa575551360ff6.1316604772.git.zkabelac@redhat.com>
References: <cover.1316604772.git.zkabelac@redhat.com>
	<498932ea49b0379d95cf520090fa575551360ff6.1316604772.git.zkabelac@redhat.com>
Message-ID: <4E79E995.5030807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/21/2011 01:36 PM, Zdenek Kabelac wrote:
> Patch fixes two reads in the iteration loop,
> where only every second lock is then passed to restarted clvmd.
> 
> Also moves initialisation of  'hn' to NULL - since for the first loop
> it's already initialized to NULL, while the second loop
> needs to start with 'hn' == NULL.

Ack. (I wonder that nobody noticed yet!)

Milan


