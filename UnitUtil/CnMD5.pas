{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2005 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

{******************************************************************************}
{        该单元基于Ronald L. Rivest的MD5.pas改写，以下是MD5.pas的声明：        }
{ -----------------------------------------------------------------------------}
{                                                                              }
{                                 MD5 Message-Digest for Delphi 4              }
{                                                                              }
{                                 Delphi 4 Unit implementing the               }
{                      RSA Data Security, Inc. MD5 Message-Digest Algorithm    }
{                                                                              }
{                          Implementation of Ronald L. Rivest's RFC 1321       }
{                                                                              }
{                      Copyright ?1997-1999 Medienagentur Fichtner & Meyer     }
{                                  Written by Matthias Fichtner                }
{                                                                              }
{ -----------------------------------------------------------------------------}
{        See RFC 1321 for RSA Data Security's copyright and license notice!    }
{ -----------------------------------------------------------------------------}
{        The latest release of md5.pas will always be available from           }
{        the distribution site at: http://www.fichtner.net/delphi/md5/         }
{ -----------------------------------------------------------------------------}
{                       Please send questions, bug reports and suggestions     }
{                      regarding this code to: mfichtner@fichtner-meyer.com    }
{ -----------------------------------------------------------------------------}
{                        This code is provided "as is" without express or      }
{                     implied warranty of any kind. Use it at your own risk.   }
{******************************************************************************}
unit CnMD5;

{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：MD5算法单元
* 单元作者：何清（QSoft） hq.com@263.net; http://qsoft.51.net
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnMD5.pas,v 1.2 2005/05/01 07:29:59 passion Exp $
* 修改记录：2003.09.18 V1.1
*               好不容易找到了该单元原作者的版权声明
*           2003.09.18 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows,Classes,SysUtils,Forms;

type
  TMD5Count = array[0..1] of DWORD;
  TMD5State = array[0..3] of DWORD;
  TMD5Block = array[0..15] of DWORD;
  TMD5CBits = array[0..7] of byte;
  TMD5Digest = array[0..15] of byte;
  TMD5Buffer = array[0..63] of byte;

  TMD5Context = record
    State: TMD5State;
    Count: TMD5Count;
    Buffer: TMD5Buffer;
  end;

  TMD5BufArray = class
  private
    MD5Context : TMD5Context;
  public
    constructor Create;
    procedure MD5(Buf : TByteArray; BufSize : Integer);
    function getResult : TMD5Digest;
  end;

procedure MD5Init(var Context: TMD5Context);
procedure MD5Update(var Context: TMD5Context; Input: PansiChar; Length: longword);
procedure MD5Final(var Context: TMD5Context; var Digest: TMD5Digest);

//----------------------------------------------------------------
// 用户API函数定义
//----------------------------------------------------------------

function MD5Buffer(const Buffer; Count: Longword): TMD5Digest;
{* 对数据块进行MD5转换
 |<PRE>
   const Buffer     - 要计算的数据块
   Count: Longword  - 数据块长度
 |</PRE>}

function MD5String(const Str: string): TMD5Digest;
{* 对String类型数据进行MD5转换
 |<PRE>
   Str: string       - 要计算的字符串
 |</PRE>}

function MD5File(const FileName: string): TMD5Digest;
{* 对指定文件数据进行MD5转换
 |<PRE>
   FileName: string  - 要计算的文件名
 |</PRE>}

function MD5Print(const Digest: TMD5Digest): string;
{* 以十六进制格式输出MD5计算值
 |<PRE>
   Digest: TMD5Digest  - 指定的MD5计算值
 |</PRE>}

function MD5Match(const D1, D2: TMD5Digest): boolean;
{* 比较两个MD5计算值是否相等
 |<PRE>
   D1: TMD5Digest   - 需要比较的MD5计算值
   D2: TMD5Digest   - 需要比较的MD5计算值
 |</PRE>}

function MD5FileStream(FilePath : string): TMD5Digest;
implementation

var
  PADDING: TMD5Buffer = (
    $80, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
    );


function F(x, y, z: DWORD): DWORD;
asm
  // Result := (x and y) or ((not x) and z);
  AND EDX, EAX
  NOT EAX
  AND EAX, ECX
  OR EAX, EDX
end;

function G(x, y, z: DWORD): DWORD;
asm
  //Result := (x and z) or (y and (not z));
  AND EAX, ECX
  NOT ECX
  AND EDX, ECX
  OR EAX, EDX
end;

function H(x, y, z: DWORD): DWORD;
asm
  //Result := x xor y xor z;
  XOR EAX, EDX
  XOR EAX, ECX
end;

function I(x, y, z: DWORD): DWORD;
asm
  //Result := y xor (x or (not z));
  NOT ECX
  OR EAX, ECX
  XOR EAX, EDX
end;


procedure rot(var x: DWORD; n: BYTE);
asm
  //x := (x shl n) or (x shr (32 - n));
  PUSH EBX
  MOV CL, $20
  SUB CL, DL
  MOV EBX, [EAX]
  SHR EBX, CL
  MOV ECX, EDX
  MOV EDX, [EAX]
  SHL EDX, CL
  OR EBX, EDX
  MOV [EAX], EBX
  POP EBX
end;

procedure FF(var a: DWORD; b, c, d, x: DWORD; s: BYTE; ac: DWORD);
begin
  inc(a, F(b, c, d) + x + ac);
  rot(a, s);
  inc(a, b);
end;

procedure GG(var a: DWORD; b, c, d, x: DWORD; s: BYTE; ac: DWORD);
begin
  inc(a, G(b, c, d) + x + ac);
  rot(a, s);
  inc(a, b);
end;

procedure HH(var a: DWORD; b, c, d, x: DWORD; s: BYTE; ac: DWORD);
begin
  inc(a, H(b, c, d) + x + ac);
  rot(a, s);
  inc(a, b);
end;

procedure II(var a: DWORD; b, c, d, x: DWORD; s: BYTE; ac: DWORD);
begin
  inc(a, I(b, c, d) + x + ac);
  rot(a, s);
  inc(a, b);
end;

// Encode Count bytes at Source into (Count / 4) DWORDs at Target

procedure Encode(Source, Target: pointer; Count: longword);
var
  S: PByte;
  T: PDWORD;
  I: longword;
begin
  S := Source;
  T := Target;
  for I := 1 to Count div 4 do
  begin
    T^ := S^;
    inc(S);
    T^ := T^ or (S^ shl 8);
    inc(S);
    T^ := T^ or (S^ shl 16);
    inc(S);
    T^ := T^ or (S^ shl 24);
    inc(S);
    inc(T);
  end;
end;

// Decode Count DWORDs at Source into (Count * 4) Bytes at Target

procedure Decode(Source, Target: pointer; Count: longword);
var
  S: PDWORD;
  T: PByte;
  I: longword;
begin
  S := Source;
  T := Target;
  for I := 1 to Count do
  begin
    T^ := S^ and $FF;
    inc(T);
    T^ := (S^ shr 8) and $FF;
    inc(T);
    T^ := (S^ shr 16) and $FF;
    inc(T);
    T^ := (S^ shr 24) and $FF;
    inc(T);
    inc(S);
  end;
end;

// Transform State according to first 64 bytes at Buffer

procedure Transform(Buffer: pointer; var State: TMD5State);
var
  a, b, c, d: DWORD;
  Block: TMD5Block;
begin
  Encode(Buffer, @Block, 64);
  a := State[0];
  b := State[1];
  c := State[2];
  d := State[3];
  FF(a, b, c, d, Block[0], 7, $D76AA478);
  FF(d, a, b, c, Block[1], 12, $E8C7B756);
  FF(c, d, a, b, Block[2], 17, $242070DB);
  FF(b, c, d, a, Block[3], 22, $C1BDCEEE);
  FF(a, b, c, d, Block[4], 7, $F57C0FAF);
  FF(d, a, b, c, Block[5], 12, $4787C62A);
  FF(c, d, a, b, Block[6], 17, $A8304613);
  FF(b, c, d, a, Block[7], 22, $FD469501);
  FF(a, b, c, d, Block[8], 7, $698098D8);
  FF(d, a, b, c, Block[9], 12, $8B44F7AF);
  FF(c, d, a, b, Block[10], 17, $FFFF5BB1);
  FF(b, c, d, a, Block[11], 22, $895CD7BE);
  FF(a, b, c, d, Block[12], 7, $6B901122);
  FF(d, a, b, c, Block[13], 12, $FD987193);
  FF(c, d, a, b, Block[14], 17, $A679438E);
  FF(b, c, d, a, Block[15], 22, $49B40821);
  GG(a, b, c, d, Block[1], 5, $F61E2562);
  GG(d, a, b, c, Block[6], 9, $C040B340);
  GG(c, d, a, b, Block[11], 14, $265E5A51);
  GG(b, c, d, a, Block[0], 20, $E9B6C7AA);
  GG(a, b, c, d, Block[5], 5, $D62F105D);
  GG(d, a, b, c, Block[10], 9, $2441453);
  GG(c, d, a, b, Block[15], 14, $D8A1E681);
  GG(b, c, d, a, Block[4], 20, $E7D3FBC8);
  GG(a, b, c, d, Block[9], 5, $21E1CDE6);
  GG(d, a, b, c, Block[14], 9, $C33707D6);
  GG(c, d, a, b, Block[3], 14, $F4D50D87);
  GG(b, c, d, a, Block[8], 20, $455A14ED);
  GG(a, b, c, d, Block[13], 5, $A9E3E905);
  GG(d, a, b, c, Block[2], 9, $FCEFA3F8);
  GG(c, d, a, b, Block[7], 14, $676F02D9);
  GG(b, c, d, a, Block[12], 20, $8D2A4C8A);
  HH(a, b, c, d, Block[5], 4, $FFFA3942);
  HH(d, a, b, c, Block[8], 11, $8771F681);
  HH(c, d, a, b, Block[11], 16, $6D9D6122);
  HH(b, c, d, a, Block[14], 23, $FDE5380C);
  HH(a, b, c, d, Block[1], 4, $A4BEEA44);
  HH(d, a, b, c, Block[4], 11, $4BDECFA9);
  HH(c, d, a, b, Block[7], 16, $F6BB4B60);
  HH(b, c, d, a, Block[10], 23, $BEBFBC70);
  HH(a, b, c, d, Block[13], 4, $289B7EC6);
  HH(d, a, b, c, Block[0], 11, $EAA127FA);
  HH(c, d, a, b, Block[3], 16, $D4EF3085);
  HH(b, c, d, a, Block[6], 23, $4881D05);
  HH(a, b, c, d, Block[9], 4, $D9D4D039);
  HH(d, a, b, c, Block[12], 11, $E6DB99E5);
  HH(c, d, a, b, Block[15], 16, $1FA27CF8);
  HH(b, c, d, a, Block[2], 23, $C4AC5665);
  II(a, b, c, d, Block[0], 6, $F4292244);
  II(d, a, b, c, Block[7], 10, $432AFF97);
  II(c, d, a, b, Block[14], 15, $AB9423A7);
  II(b, c, d, a, Block[5], 21, $FC93A039);
  II(a, b, c, d, Block[12], 6, $655B59C3);
  II(d, a, b, c, Block[3], 10, $8F0CCC92);
  II(c, d, a, b, Block[10], 15, $FFEFF47D);
  II(b, c, d, a, Block[1], 21, $85845DD1);
  II(a, b, c, d, Block[8], 6, $6FA87E4F);
  II(d, a, b, c, Block[15], 10, $FE2CE6E0);
  II(c, d, a, b, Block[6], 15, $A3014314);
  II(b, c, d, a, Block[13], 21, $4E0811A1);
  II(a, b, c, d, Block[4], 6, $F7537E82);
  II(d, a, b, c, Block[11], 10, $BD3AF235);
  II(c, d, a, b, Block[2], 15, $2AD7D2BB);
  II(b, c, d, a, Block[9], 21, $EB86D391);
  inc(State[0], a);
  inc(State[1], b);
  inc(State[2], c);
  inc(State[3], d);
end;

// Initialize given Context

procedure MD5Init(var Context: TMD5Context);
begin
  with Context do
  begin
    State[0] := $67452301;
    State[1] := $EFCDAB89;
    State[2] := $98BADCFE;
    State[3] := $10325476;
    Count[0] := 0;
    Count[1] := 0;
    ZeroMemory(@Buffer, SizeOf(TMD5Buffer));
  end;
end;

// Update given Context to include Length bytes of Input

procedure MD5Update(var Context: TMD5Context; Input: PansiChar; Length: longword);
var
  Index: longword;
  PartLen: longword;
  I: longword;
begin
  with Context do
  begin
    Index := (Count[0] shr 3) and $3F;
    inc(Count[0], Length shl 3);
    if Count[0] < (Length shl 3) then inc(Count[1]);
    inc(Count[1], Length shr 29);
  end;

  PartLen := 64 - Index;
  if Length >= PartLen then
  begin
    CopyMemory(@Context.Buffer[Index], Input, PartLen);
    Transform(@Context.Buffer, Context.State);
    I := PartLen;
    while I + 63 < Length do
    begin
      Transform(@Input[I], Context.State);
      inc(I, 64);
    end;
    Index := 0;
  end
  else I := 0;
  CopyMemory(@Context.Buffer[Index], @Input[I], Length - I);
end;

// Finalize given Context, create Digest and zeroize Context

procedure MD5Final(var Context: TMD5Context; var Digest: TMD5Digest);
var
  Bits: TMD5CBits;
  Index: longword;
  PadLen: longword;
begin
  Decode(@Context.Count, @Bits, 2);
  Index := (Context.Count[0] shr 3) and $3F;
  if Index < 56 then
    PadLen := 56 - Index
  else
    PadLen := 120 - Index;
  MD5Update(Context, @PADDING, PadLen);
  MD5Update(Context, @Bits, 8);
  Decode(@Context.State, @Digest, 4);
  ZeroMemory(@Context, SizeOf(TMD5Context));
end;

//----------------------------------------------------------------
// 用户API函数实现
//----------------------------------------------------------------

// 对数据块进行MD5转换

function MD5Buffer(const Buffer; Count: Longword): TMD5Digest;
var
  Context: TMD5Context;
begin
  MD5Init(Context);
  MD5Update(Context, Pansichar(Buffer), Count);
  MD5Final(Context, Result);
end;


function MD5FileStream(FilePath : string): TMD5Digest;
var
  Context: TMD5Context;
  buf : TByteArray;
  FileStream : TFileStream;
  i : Integer;
  RemainSize : Int64;
  BufSize : Integer;
begin
  MD5Init(Context);

  FileStream := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  RemainSize := FileStream.Size;
  BufSize := SizeOf(buf);
  while RemainSize > 0 do
  begin
    if BufSize > RemainSize then
      BufSize := RemainSize;
    FileStream.Read( buf, BufSize );
    RemainSize := RemainSize - BufSize;

    MD5Update(Context, @buf, BufSize);
  end;
  FileStream.Free;

  MD5Final(Context, Result);
end;

// 对String类型数据进行MD5转换

function MD5String(const Str: string): TMD5Digest;
var
  Context: TMD5Context;
begin
  MD5Init(Context);
  MD5Update(Context, PansiChar(Str), length(Str));
  MD5Final(Context, Result);
end;

// 对指定文件数据进行MD5转换

function MD5File(const FileName: string): TMD5Digest;
var
  FileHandle: THandle;
  MapHandle: THandle;
  ViewPointer: pointer;
  Context: TMD5Context;
begin
  MD5Init(Context);
  FileHandle := CreateFile(pChar(FileName), GENERIC_READ, FILE_SHARE_READ or
    FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or
    FILE_FLAG_SEQUENTIAL_SCAN, 0);
  if FileHandle <> INVALID_HANDLE_VALUE then
  try
    MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, 0, nil);
    if MapHandle <> 0 then
    try
      ViewPointer := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, 0, 0);
      if ViewPointer <> nil then
      try
        MD5Update(Context, ViewPointer, GetFileSize(FileHandle, nil));
      finally
        UnmapViewOfFile(ViewPointer);
      end;
    finally
      CloseHandle(MapHandle);
    end;
  finally
    CloseHandle(FileHandle);
  end;
  MD5Final(Context, Result);
end;

// 以十六进制格式输出MD5计算值

function MD5Print(const Digest: TMD5Digest): string;
var
  I: byte;
const
  Digits: array[0..15] of char = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := '';
  for I := 0 to 15 do
    Result := Result + Digits[(Digest[I] shr 4) and $0F] +
      Digits[Digest[I] and $0F];
end;

// 比较两个MD5计算值是否相等

function MD5Match(const D1, D2: TMD5Digest): boolean;
var
  I: byte;
begin
  I := 0;
  Result := TRUE;
  while Result and (I < 16) do
  begin
    Result := D1[I] = D2[I];
    inc(I);
  end;
end;

{ TMD5BufArray }

constructor TMD5BufArray.Create;
begin
  MD5Init( MD5Context );
end;

function TMD5BufArray.getResult: TMD5Digest;
begin
  MD5Final( MD5Context, Result );
end;

procedure TMD5BufArray.MD5(Buf: TByteArray; BufSize : Integer);
begin
  MD5Update( MD5Context, @Buf, BufSize );
end;

end.
