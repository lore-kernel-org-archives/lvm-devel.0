From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Nov 2008 16:46:13 +0100
Subject: [PATCH] (5/11) vg_read error returns, part 1
In-Reply-To: <1227499830.6608.32.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Sun, 23 Nov 2008 23:10:30 -0500")
References: <87fxme3qo0.fsf@eriador.mornfall.net>
	<1227499830.6608.32.camel@localhost.localdomain>
Message-ID: <87r6516sai.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

>> -int vg_check_status(const struct volume_group *vg, uint32_t status)
>> +static int _vg_check_status(const struct volume_group *vg, uint32_t
>> status)
>>  {
>> +       uint32_t ret = 0;
>>         if ((status & CLUSTERED) &&
>>             (vg_is_clustered(vg)) && !locking_is_clustered() &&
>>             !lockingfailed()) {
>>                 log_error("Skipping clustered volume group %s",
>> vg->name);
>> -               return 0;
>> +               ret |= FAILED_CLUSTERED;
>> 
>
> Need uint32_t for function return value consistency with internal
> variable.  Probably want to move/fix the comment as well.
Good catch, noting down.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


