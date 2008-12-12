From: Petr Rockai <prockai@redhat.com>
Date: Fri, 12 Dec 2008 10:20:49 +0100
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <1229027813.20795.15.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Thu, 11 Dec 2008 15:36:53 -0500")
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
	<1229027813.20795.15.camel@localhost.localdomain>
Message-ID: <87ljulbvgu.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> On Tue, 2008-12-09 at 17:44 +0100, Petr Rockai wrote:
>>  /* FIXME: remove redundant vg_name */
>>  int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
>> -                    struct volume_group *vg, int consistent,
>> +                    struct volume_group *vg,
>>                      force_t force __attribute((unused)))
>>  {
>>         struct physical_volume *pv;
>> @@ -340,7 +340,7 @@ int vg_remove_single(struct cmd_context 
>>         unsigned lv_count;
>>         int ret = 1;
>>  
>> -       if (!vg || !consistent || vg_missing_pv_count(vg)) {
>> +       if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
>>                 log_error("Volume group \"%s\" not found, is
>> inconsistent "
>>                           "or has PVs missing.", vg_name);
>>                 log_error("Consider vgreduce --removemissing if
>> metadata "
>
> Did you mean to put this in the second patch?
Actually, hard to tell. It, after all, is part of the library, for a reason or
other. It belongs equally well to the first as to the second patch. What do you
propose?

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


