Received: from sonic.asd.mail.yahoo.com (sonic302-3.consmr.mail.bf2.yahoo.com [74.6.135.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3872121C179
	for <lvm-devel@lists.linux.dev>; Wed,  6 Aug 2025 23:36:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.6.135.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754523400; cv=none; b=fP00D3moLA1FtBBubIuwbNK/o5A2bLj2TDswf3jjpbefaGRtdpLTz9rTmfika61+rirSuzo+wnCFVw4QV34GyLnQMWszzYW8yDWeSVrNIDk4B3C7kMFtJGXXYGHWiI59g3KSmpw2ZCXA4P9EFaqLcZ+99P6n/2qkYLbxcVo40ag=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754523400; c=relaxed/simple;
	bh=lhHwBd3UoN1yPVCFp6DUT1NM6EZQhdmDxaFFi0Y3EmM=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=JWgM6epa/08dqw2ZxYShiVZd+Cs6+WzlHZFsrB62wrVopd64dtQI1r38w8eVJEZpjScM5IL8zpY2EkgBcUlqIWKDlhUuljUwtYqp3ft05RKwT6f22LHMVWZETKZX6Kmn8WHRiYYTsmxRvFyXonDrN83k8nYZW6q4Jj1tAdno9Yc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=yahoo.com; spf=pass smtp.mailfrom=yahoo.com; dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b=mDL3ofqE; arc=none smtp.client-ip=74.6.135.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=yahoo.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=yahoo.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="mDL3ofqE"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1754523365; bh=lhHwBd3UoN1yPVCFp6DUT1NM6EZQhdmDxaFFi0Y3EmM=; h=Date:From:To:Cc:In-Reply-To:References:Subject:From:Subject:Reply-To; b=mDL3ofqERtoTu1DO8h8oR40KYwWZQWNJrBXZyI5p+29ZKTNfb4PWHN1MUvoKz8yr4rQzRruX2E5/vV3nT5Mty7sf3WUUKp6CAhHqKvvV3NDGQ8PwkWafOsll7LYGjX4+xXYMHaedqzTGZnXEXR/RcO15KV6KaGbkO3UzLfZMAn21IFImWyK7zqMhek3VkFUssRTyK1AKtJmbafZ1oqL+MgfW3+9T+VTLaBy/LVGCIaYb1vZVver/RvuUTHzInTAZJyiEn9GeUd5I4g6wd3m85odxGWsnWEQyKRRptr6lh9mZ0Y0sVIZc1HKtAKr4Od8sVkdgpR5ETWMAF2fGNxpBKQ==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1754523365; bh=04PBOmzrXN31i4gGMNx25dus98+82EG6QN5FPA/0sFI=; h=X-Sonic-MF:Date:From:To:Subject:From:Subject; b=MmNy2/R+7/Q+3atD1n4EuPiLhsK5tXhSSoPz8DicRE0WI2FD/R+PZM3NRdAM77Pf+A0i/Od8iSgfueqnHoK1iL/ICgjL/0GQcpl/u10/WRQONRT78+TNwa1nWCtT2jNhKsHXxNeffw32hRYeDbzezuQfTz400el7ACxUlsCo+v6oFitoNnH9rEZGJvw32hxp/Fy86Ox7kjaOPmcbi+mrwqD7IYoKAns9EJM6gl6RWuYAv8UDEqE0S7NFNyGROezxBUUXHksNEP0CF15Grnwm7j2lQd6XShZ+/IKcxzR09YTr8Ws7Pv1uJfUPofNqy/Biwcb69RN01LMqZsrl7vK6Pg==
X-YMail-OSG: VuZ_65YVM1kmqTAuFDg4HQ0zKlYTM8CE66y_10pLMNgDpHwUVHA.Yf7mbxfkxjX
 EseAR0xcpUxHQ0vm8FyWJ2hZo.3XHpbmpKTEtigj9QyvFB3sGZD_FEEt20wpYtEv4BeNz9xBbxsK
 D1FGKIOyaNZ0WpCpDrfGD4F.yTWOW3hestoBeaYwBSh2dZO3hkjMUcnuLvUpb11wgxbQLhgI4SZ.
 sqGXkM8E_ebzNZw4Cknc.UT87YV5H.CyjIzCvo_AuA912F8K6U621ddHh6MUjQVJTrlpESnew0bs
 DjY1RZqsDyoQztJCPlhNLoDo9S0KXmvvBOpXAXjxHUv25OCLxc5LmMwb8d5yeU7Iody2_IwfIWdj
 kQ7yJvm2a.yd6M.3LBT3f2PUTlvhcOpUwmsb1Xjl9987XTrIMY2UYgT0l3t.RfVDpeZEXaPKeCbE
 tDBGsmgepY0opOH6OTpHpSMrHdKWR1b5HNDWqfcY4tXB8KWvOEi07AeF54HI2Q.RNziUM3zRMISp
 waKXUxVUtKdTQ7FvObNygAC2aiXWGUrgBvuAeIrsC98V8ojgWvt1ule4eXahcA7jul8bSq7D6gXp
 723zGE8ZM8yRDAKxIjvmZvkF7ULF2BLRY5ldHoph2ilNhvSvco_6Se_VE8aCbuNkvtbj_IFDDRow
 uzCNFeEdQsk4JpoRwY0iVTaSjklkka9sabUtpj4JN4wbubgb4LgOa3s3hnW.Dzor2OBKs2.xFGyU
 LKdXbZzaQ92z9C6MliY2CdM__NsIldQnG9VSi56dvV_fuOkH4hKyiNJQ2.Vl41EtFaEMeONrQGqd
 YYRYGYxoTh0s1jzvtXA2bm3SfTFd5wfUSacCCfhOOnTJlXQ7yv94ydyH1IB2Fb51_B8Do8rIe_E2
 vwnRaf3sVrmfUjC2dXrPCCwjMxAFI3hp5bOIE98a64GwuzKtzGfk4_uo8YuyuD970ikrBv8XG6y4
 sFDRF1ZE76.wNrp3rHZp4yBq2AWsi9tfiYPcQAh4iXHWhWQivtlmD7yL4JPw4cFsKR8F5JUz46Hl
 2N9sD6C3IHA7STJmsy.xhM7oiTYM1nV3Kj2FknmijYdNfYXKsMv.IxPs_Vqn6LukeF45njewOQ62
 6Wl14v1yR1Ew.daPviaruRdzRy9MaUkQ8BkVACZz6G1VS96RJ_NZ601Uc0R3OJk5OhaCHaehWyKl
 zBMRlAyxbP8NBlz8X2esgd4sYoTknD8a0MXdOOxibirrbZY0tqwhJPGatLwG.RUOuPzTkFcBZAKZ
 3LbejyXjFI9H5dWqO2kzkLIS5I_aJgSM5EONsjksEsUtlPpOjTpKucKHDWsIUFaSzaYb.ZgHrvIp
 8sp8GypZBrFmQcd8dP7i_Y2YJHb_5F4NkxNLSksQoLuCeOMPAVGX.mcxO46pnOGJy__f_qCSopFg
 QkTfCBcWR3L3u_pkdS_1SjL2hjaLEdY.2Xzu5rnTj.MwAn.MPNuVe6cUjxBa5mCYmwJXakTBK_DT
 vrq_l6BILNLNhJT.UiNVP.FNCGHJnvZAVYjxq_9UXq2kiSoCJFUIzRbpYjtqsxegYuGJUe1feCul
 iWOj3nlNsGk74m59nhNu1wFkdi804t9h.Du_YGYo6GEEH7BEyJEZ3wGvQVENv_wyJu0RNtnlfv5e
 a2p8GZRBtDCSZOYgQNdfkPNL7BTmBC0nWWqOZHuTlSIs8tz3VYtMU6kRoIuhW2sq15QVyyMF7Far
 0EBC4nZqRTeje0NENrE14vJiDWCzc7BdBh670.0DQK4qlXHp8KXzI7V1J3LV31x1ro3d.pDV3809
 CYlbo5zRPRxQQCi49S3qrmcVnN_7cVva94dWDBbqlmOY2XSTBa2b5c6sLk6jnX2meqHl62wrMjFM
 PIr26PypOIBldAzIUrrX9LSSzc7x8tiRBgJ_OZ3Sy6finiPU9E7ToISN0KPhSQP7f3hvQT.CpItm
 mECZezXK3qld048SqjEq3UAexSG7oMzlC3Ee3X1YGgW25RFxIV4DE9BWz69J2QkiusLznNfjOWlj
 mt3nYZkbyfH2m07fd6XrMCvpuIL4PsHiesaGPe1XWvhoy2hPiRzqvoa2KuC.rmrH5MWI4RKqq.Ph
 _cQsjDyFkBUjiZnDySolrQgjxRGVIrdujH24zuppuFkONleb6_Dmwb8cJs_2wNqZaTiSZVj4UUIC
 dbyIPKMb315A0nv6EjplaD_ssGmg9GWOov4KokHLMh0iCPsswTHSJkwZcVgqM8VgqdUUNLHYWE1j
 ZlnpAHxvRO1eLmTd0o6rP
X-Sonic-MF: <pattonme@yahoo.com>
X-Sonic-ID: fa62377c-4fa2-4119-a4c6-458c7adc2296
Received: from sonic.gate.mail.ne1.yahoo.com by sonic302.consmr.mail.bf2.yahoo.com with HTTP; Wed, 6 Aug 2025 23:36:05 +0000
Date: Wed, 6 Aug 2025 23:25:26 +0000 (UTC)
From: matthew patton <pattonme@yahoo.com>
To: "linux-lvm@lists.linux.dev" <linux-lvm@lists.linux.dev>
Cc: "lvm-devel@lists.linux.dev" <lvm-devel@lists.linux.dev>
Message-ID: <584283844.1499801.1754522726622@mail.yahoo.com>
In-Reply-To: <26771.51188.491376.658337@quad.stoffel.home>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com> <26771.51188.491376.658337@quad.stoffel.home>
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Mailer: WebService/1.1.24260 YMailNorrin

 > The problem is that the raid1 implementation may freely choose which leg
> to read from. If it chooses to read from the non-corrupted leg, the
> corruption is not detected,=C2=A0

which is why man invented ZFS. :)

I don't know what the probability 10^-X is of silent mismatch between halve=
s of a mirror, but it's a fatal weakness IMO of pretty much every RAID sche=
me out there that doesn't checksum each block be it at the "disk sector" (5=
12/4k) or "filesystem" (4k).

Would it make sense for LVM since it's a shim between disk device and files=
ystems to implement its own checksum scheme? Maybe do it at a "LVM page" no=
tion of 32 disk sectors followed by a couple of extra disk sectors in which=
 the checksum for each of the preceding 32 is strung together in one packed=
 value? /spit-ball

The *best* answer is for everyone to move to 520/528 byte sectors like seri=
ous storage vendors did 50 years ago, but I suspect that would be harder to=
 get past the gatekeepers than drivers written in RUST.

