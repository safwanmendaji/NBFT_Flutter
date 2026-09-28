$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$lib = Join-Path $root 'lib'
# Exact approved pairs from the immediately preceding request.
$pairs = @(
  @('lib/widgets/customize_appbar.dart','lib/widgets/customize_app_bar.dart'),
  @('lib/widgets/customize_bottomtab.dart','lib/widgets/customize_bottom_tab.dart'),
  @('lib/widgets/customize_cachedimage.dart','lib/widgets/customize_cached_image.dart'),
  @('lib/widgets/customize_imagepicker.dart','lib/widgets/customize_image_picker.dart'),
  @('lib/widgets/customize_shimmer.dart','lib/widgets/customize_shimmer.dart'),
  @('lib/widgets/customize_textformfield.dart','lib/widgets/customize_text_form_field.dart'),
  @('lib/widgets/customize_textwidget.dart','lib/widgets/customize_text_widget.dart'),
  @('lib/widgets/custom_dropdowncell.dart','lib/widgets/custom_dropdown_cell.dart'),
  @('lib/widgets/custom_headerlogo.dart','lib/widgets/custom_header_logo.dart'),
  @('lib/widgets/custom_profileoption.dart','lib/widgets/custom_profile_option.dart'),
  @('lib/widgets/your_propertycell.dart','lib/widgets/your_property_cell.dart'),
  @('lib/widgets/propertycell.dart','lib/widgets/property_cell.dart'),
  @('lib/widgets/customer_cardcell.dart','lib/widgets/customer_card_cell.dart'),
  @('lib/core/dialogs/customize_alertdialog.dart','lib/core/dialogs/customize_alert_dialog.dart'),
  @('lib/core/extensions/stringextension.dart','lib/core/extensions/string_extension.dart'),
  @('lib/core/utils/appnavigator.dart','lib/core/utils/app_navigator.dart'),
  @('lib/core/utils/navigationutils.dart','lib/core/utils/navigation_utils.dart'),
  @('lib/models/local_successmodel.dart','lib/models/local_success_model.dart'),
  @('lib/models/notifications/notificationmodel.dart','lib/models/notifications/notification_model.dart'),
  @('lib/models/properties/propertiesmodel.dart','lib/models/properties/properties_model.dart'),
  @('lib/models/properties/statuschangemodel.dart','lib/models/properties/status_change_model.dart'),
  @('lib/screens/dashboard/dashboard.dart','lib/screens/dashboard/dashboard_model.dart'),
  @('lib/screens/add_properties/add_properties.dart','lib/screens/add_property/add_property.dart'),
  @('lib/screens/add_properties/add_property_model.dart','lib/screens/add_property/add_property_model.dart'),
  @('lib/screens/add_properties/add_property_screen.dart','lib/screens/add_property/add_property_screen.dart'),
  @('lib/screens/add_properties/add_properties_controller.dart','lib/screens/add_property/add_property_controller.dart')
)
function Resolve-ActualChild([string]$parent,[string]$leaf) {
  if (-not (Test-Path -LiteralPath $parent -PathType Container)) { return $null }
  return Get-ChildItem -LiteralPath $parent -Force | Where-Object { $_.Name -ceq $leaf } | Select-Object -First 1
}
function Move-CaseAware([string]$src,[string]$dst) {
  $sp = Split-Path -LiteralPath $src -Parent; $sn = Split-Path -LiteralPath $src -Leaf
  $dp = Split-Path -LiteralPath $dst -Parent; $dn = Split-Path -LiteralPath $dst -Leaf
  $s = Resolve-ActualChild $sp $sn
  $d = Resolve-ActualChild $dp $dn
  if ($s -and -not $d) {
    if ($sp -ieq $dp -and $sn -ine $dn) {
      $tmp = Join-Path $sp ('__tmp_' + [guid]::NewGuid().ToString('N'))
      Rename-Item -LiteralPath $s.FullName -NewName (Split-Path -LiteralPath $tmp -Leaf)
      Rename-Item -LiteralPath $tmp -NewName $dn
    } else {
      if (-not (Test-Path -LiteralPath $dp -PathType Container)) { New-Item -ItemType Directory -Path $dp -Force | Out-Null }
      Move-Item -LiteralPath $s.FullName -Destination $dst
    }
  }
}
foreach ($p in $pairs) {
  $src = Join-Path $root $p[0]; $dst = Join-Path $root $p[1]
  # Resolve and normalize any case-only folder segments through an intermediate name.
  $parts = $p[1] -split '[\\/]'; $cur = $root
  for ($i=0; $i -lt ($parts.Count-1); $i++) {
    $actual = Resolve-ActualChild $cur $parts[$i]
    if ($actual -and $actual.Name -cne $parts[$i]) {
      $tmpName = '__tmp_' + [guid]::NewGuid().ToString('N')
      Rename-Item -LiteralPath $actual.FullName -NewName $tmpName
      Rename-Item -LiteralPath (Join-Path $cur $tmpName) -NewName $parts[$i]
    }
    $cur = Join-Path $cur $parts[$i]
  }
  Move-CaseAware $src $dst
}
# Remove only empty directories under lib, deepest first.
Get-ChildItem -LiteralPath $lib -Directory -Recurse | Sort-Object FullName -Descending | ForEach-Object {
  if (@(Get-ChildItem -LiteralPath $_.FullName -Force).Count -eq 0) { Remove-Item -LiteralPath $_.FullName }
}
foreach ($p in $pairs) {
  $dst = Join-Path $root $p[1]; $src = Join-Path $root $p[0]
  $de = Test-Path -LiteralPath $dst -PathType Leaf
  $sa = $false; $sp = Split-Path -LiteralPath $src -Parent; $sn = Split-Path -LiteralPath $src -Leaf
  if (Test-Path -LiteralPath $sp -PathType Container) { $sa = [bool](Get-ChildItem -LiteralPath $sp -Force | Where-Object { $_.Name -ceq $sn } | Select-Object -First 1) }
  Write-Output ("destination {0} exists: {1}; old source absent: {2}" -f $p[1],$de,(-not $sa))
}
Write-Output ("Dart file count (information only): {0}" -f @(Get-ChildItem -LiteralPath $lib -Recurse -Filter *.dart -File).Count)
Write-Output 'lib path segments containing uppercase or spaces:'
Get-ChildItem -LiteralPath $lib -Recurse -Force | ForEach-Object { $_.FullName.Substring($lib.Length+1).Split('\') } | Where-Object { $_ -cmatch '[A-Z ]' } | Sort-Object -Unique
