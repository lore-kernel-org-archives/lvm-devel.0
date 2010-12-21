From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 18:12:00 +0100
Subject: [PATCH 09/23] Add test for errors in _setup_task
In-Reply-To: <1647ec7c4651efc13dfc7125038082fcf7157765.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<1647ec7c4651efc13dfc7125038082fcf7157765.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10DFE0.6080907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> -	if (uuid && *uuid)
> -		dm_task_set_uuid(dmt, uuid);
> +	if (uuid && *uuid && !dm_task_set_uuid(dmt, uuid))
> +		goto_out;

Shouldn't it fail if uuid is requested but it is empty string?
(but that's another problem:-)

Milan


