{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lazopenqbuilder_promet;

interface

uses
  QBAbout, QBDBFrm, QBDBFrm2, QBDirFrm, qbepromet, QBLnkFrm, QBuilder, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lazopenqbuilder_promet', @Register);
end.
