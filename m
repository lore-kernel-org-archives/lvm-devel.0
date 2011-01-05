From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 00:24:13 +0000
Subject: [PATCH 09/23] Add test for errors in _setup_task
In-Reply-To: <4D11D193.3090008@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<1647ec7c4651efc13dfc7125038082fcf7157765.1292945707.git.zkabelac@redhat.com>
	<4D10DFE0.6080907@redhat.com> <4D11D193.3090008@redhat.com>
Message-ID: <20110105002413.GE10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 22, 2010 at 11:23:15AM +0100, Zdenek Kabelac wrote:
> Dne 21.12.2010 18:12, Milan Broz napsal(a):
> > On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> >> -	if (uuid && *uuid)
> >> -		dm_task_set_uuid(dmt, uuid);
> >> +	if (uuid && *uuid && !dm_task_set_uuid(dmt, uuid))
> >> +		goto_out;
> > 
> > Shouldn't it fail if uuid is requested but it is empty string?
> > (but that's another problem:-)

Is there a case for moving the "Is uuid empty?" test inside dm_task_set_uuid().
IOW if dm_task_set_uuid() is passed an empty string, I think it should erase
the existing uuid but not bother to create a new one.

Perhaps?

int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
{
        dm_free(dmt->uuid);

	if (!uuid || !*uuid)
		return 1;

        if (!(dmt->uuid = dm_strdup(uuid))) {
                log_error("dm_task_set_uuid: strdup(%s) failed", uuid);
                return 0;
        }

        return 1;
}

Alasdair


