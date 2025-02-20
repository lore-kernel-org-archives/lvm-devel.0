Received: from m16.mail.163.com (m16.mail.163.com [117.135.210.5])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id DC6D534CF5
	for <lvm-devel@lists.linux.dev>; Thu, 20 Feb 2025 01:54:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=117.135.210.5
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740016468; cv=none; b=LbXMO8cXXlc7/tEi5XqBTVtSuVlp7nYXbQeQGors1X2wiyP9YDmZXoDMmM79TCiZD0zNhw9suBjbc82q1zDxdAPMxrD1zvFaUq+rPD0d/rwf7imyI2vJlWJerxKp24bAHJuEjK1sIIrFBTzamVBV7/a720EfciuEEb3XIR/SiIA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740016468; c=relaxed/simple;
	bh=FIygzwO17oHGKkEVS3ev/tMiSQBV54O8BmyS9diK4A0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:Content-Type:
	 MIME-Version:Message-ID; b=TpkrnjUSNBayBd5WNUzrsr7BBlbQy3eQF4hiWmD3H/nrUxYJkeeQv/LJFRuC4/UjwOYUlvDAyNDRr4ysmrzcyLl+qdld84nUVa6n1gleKU4JMiIGZ2XfcesxuJtOys/35RwmyKWMuFkHE72FopQxWW1QaAquQZsZ7D9Od93tPSo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com; spf=pass smtp.mailfrom=163.com; dkim=fail (1024-bit key) header.d=163.com header.i=@163.com header.b=oco7NB08 reason="signature verification failed"; arc=none smtp.client-ip=117.135.210.5
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=163.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=163.com header.i=@163.com header.b="oco7NB08"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=Date:From:Subject:Content-Type:MIME-Version:
	Message-ID; bh=zUBt+UKrTINRq+FDYoyzWxYwvkf03+Em67rlK80kwbk=; b=o
	co7NB08KK11gj2w2eWJQVLIw5+sI4qg8p1HQBHeOuodO0fySPYhSftC4uVF+A3KU
	DKYaQa6oB/gbbOgKYVgrt1bA+zzVabnjZY/SYrj9cxfodL0hlZ5Zh6VSsbnFP5ii
	alOQeE9IpI2W1ciJq1nLY155jVHGylbpWHvoyU4lns=
Received: from zengjianqi163$163.com ( [123.150.8.43] ) by
 ajax-webmail-wmsvr-40-108 (Coremail) ; Thu, 20 Feb 2025 09:54:17 +0800
 (CST)
Date: Thu, 20 Feb 2025 09:54:17 +0800 (CST)
From: "zengjianqi163@163.co" <zengjianqi163@163.com>
To: "Zdenek Kabelac" <zdenek.kabelac@gmail.com>
Cc: "lvm-devel@lists.linux.dev" <lvm-devel@lists.linux.dev>
Subject: Re:  Fix the issue of missing symbols in libdevmapper
X-Priority: 3
X-Mailer: Coremail Webmail Server Version XT5.0.14 build 20240801(9da12a7b)
 Copyright (c) 2002-2025 www.mailtech.cn 163com
In-Reply-To: <c1d5760e-ee5f-40f8-825f-4c7f44a0aacf@gmail.com>
References: <2299fe3d.6a77.1951d2e7409.Coremail.zengjianqi163@163.com>
 <c1d5760e-ee5f-40f8-825f-4c7f44a0aacf@gmail.com>
X-NTES-SC: AL_Qu2fAvyauUwu4SCaZ+kfmk4Qh+06WMu3sv8j3IBWO5x+jCLp3gMDRnBTIkT33PmDIA22nQiHWzRI+PhKY45bfboLAiK4br5Hlz58HVyXqUGpDw==
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=UTF-8
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Message-ID: <1249d3c8.18cb.19521101544.Coremail.zengjianqi163@163.com>
X-Coremail-Locale: zh_CN
X-CM-TRANSID:bCgvCgD3nz5Ji7ZnBb1rAA--.30885W
X-CM-SenderInfo: p2hqwy5ldq1xqrwtqiywtou0bp/1tbiUQj5F2e2gxWkfQACsr
X-Coremail-Antispam: 1U5529EdanIXcx71UUUUU7vcSsGvfC2KfnxnUU==

SGkswqBaZGVuZWsKClRoaXMgaXNzdWUgaXMgbm90IGZyb20gb3RoZXIgbGliZGV2bWFwcGVyIHVz
ZXIuCkkgZGlzY292ZXJlZCB0aGlzIGlzc3VlIHdoaWxlIGNvbmR1Y3RpbmcgYSBjb21wYXRpYmls
aXR5IGFuYWx5c2lzIGJldHdlZW4gdmVyc2lvbnMgbHZtMi0yLjAzLjA5IGFuZCBsdm0yLTIuMDMu
MjEgYmVmb3JlIGFuZCBhZnRlciB0aGUgdXBncmFkZS4KCkJ5IHRoZSB3YXksIG1heSBJIGFzayBp
ZiB0aGUgZmVhc2liaWxpdHkgb2YgdGhpcyBwYXRjaCBtZWV0cyB0aGUgcmVxdWlyZW1lbnRzPyBP
biB3aGljaCBicmFuY2ggb2YgTFZNMiBjYW4gSSB2ZXJpZnkgdGhpcyBpc3N1ZSBhZnRlcndhcmQ/
CgoKLS0KQmVzdCByZWdhcmRzLgpKaWFucWkgWmVuZwoKCgotLS0tIFJlcGxpZWQgTWVzc2FnZSAt
LS0tCgpGcm9tWmRlbmVrIEthYmVsYWM8emRlbmVrLmthYmVsYWNAZ21haWwuY29tPkRhdGUyLzE5
LzIwMjUgMjM6MDZUb3plbmdqaWFucWkxNjNAMTYzLmNvPHplbmdqaWFucWkxNjNAMTYzLmNvbT4s
Cjxsdm0tZGV2ZWxAbGlzdHMubGludXguZGV2PlN1YmplY3RSZTogRml4IHRoZSBpc3N1ZSBvZiBt
aXNzaW5nIHN5bWJvbHMgaW4gbGliZGV2bWFwcGVyRG5lIDE5LiAwMi4gMjUgdiA4OjQ4IHplbmdq
aWFucWkxNjNAMTYzLmNvIG5hcHNhbChhKToKCkhp77yMbHZtLWRldmVsCiAKIEkgYW5hbHl6ZWQg
dGhlIGR5bmFtaWMgbGlicmFyeSBsaWJkZXZtYXBwZXIuc28uMS4wMiBhbmQgZm91bmQgYW4gaXNz
dWU6IGl0IAogYXBwZWFycyB0byBiZSBtaXNzaW5nIHR3byBzeW1ib2xzOiBkbV9iaXRzZXRfcGFy
c2VfbGlzdEBARE1fMV8wMl8xMzggYW5kIAogZG1fdHJlZV9ub2RlX3NpemVfY2hhbmdlZEBCYXNl
LgogCiBBbmFseXNpcyBvZiBkbV9iaXRzZXRfcGFyc2VfbGlzdEBARE1fMV8wMl8xMzg6CiAKIFRo
ZSBzeW1ib2wgZG1fYml0c2V0X3BhcnNlX2xpc3QgaXMgbGlzdGVkIGluIHRoZSBmaWxlcyAKIGxp
YmRtLy5leHBvcnRlZF9zeW1ib2xzLkRNXzFfMDJfMTI5IGFuZCBsaWJkbS8uZXhwb3J0ZWRfc3lt
Ym9scy5ETV8xXzAyXzEzOC4gCiBIb3dldmVyLCBpbiB0aGUgYWN0dWFsIHNvdXJjZSBjb2RlIGlt
cGxlbWVudGF0aW9uLCBvbmx5IAogZG1fYml0c2V0X3BhcnNlX2xpc3RAQERNXzFfMDJfMTI5IGlz
IGV4cGxpY2l0bHkgZGVmaW5lZC4KClllcCAtIHRoYW5rcyBmb3IgdGhlIHBhdGNoLgoKSSdtIGp1
c3Qgd29uZGVyaW5nIGhvdyBkaWQgeW91IGhpdCB0aGUgaXNzdWUgLSBpcyB0aGlzIGZyb20gc29t
ZSBvdGhlciAKbGliZGV2bWFwcGVyIHVzZXIgPwoKKEFzIGx2bTIgaXMgdXNpbmcgaXQncyBpbnRl
cm5hbCBjb3B5IHRoZXNlIGRheXMgLSBzbyB0aGVyZSBjYW5ub3QgYmUgYSBwcm9ibGVtIAp3aXRo
IGxpbmtpbmcgdGhpcyBzeW1ib2wgd2l0aGluIGx2bTIuKQoKUmVnYXJkcwoKWmRlbmVrCg==
