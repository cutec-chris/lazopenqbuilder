{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lazopenqbuilder_zeos;

interface

uses
  QBAbout, QBDBFrm, QBDBFrm2, QBDirFrm, QBEZEOS, QBLnkFrm, QBuilder, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lazopenqbuilder_zeos', @Register);
end.
