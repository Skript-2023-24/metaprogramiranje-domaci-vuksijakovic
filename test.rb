load 'skripta.rb'
session = GoogleDrive::Session.from_config("config.json")

ws = session.spreadsheet_by_key("1tQa-tzq1BYYCtvqXM0eC2YFLZgRakfkY6tgZIVGRgOg").worksheets[0]
ws2 = session.spreadsheet_by_key("1tQa-tzq1BYYCtvqXM0eC2YFLZgRakfkY6tgZIVGRgOg").worksheets[1]
tabela = GoogleSheets.new(ws)
#Vracanje tabele kao 2D niz
niz = tabela.matrixBack
niz.each do |row|
    p row
end
print "\n"
#Pristupanje redu preko tabela.row(1) npr
p tabela.row(1)
tabela2 = GoogleSheets.new(ws2)
#Each funkcija
print "\n"
tabela.each do |cell|
    p cell
end
print "\n"
#upit t["Prva Kolona"], pristup elementu preko t["Prva Kolona"][1] 
#i dodjeljivanje vrijednosti preko t["Prva Kolona"][1] = "vrijednost"
p tabela["foo"]
tabela["foo"][1] = 5
p tabela["foo"][1]
tabela["foo"][1] = "promjena"
p tabela["foo"][1]
print "\n"

# pristup kolonama preko t.prvaKolona, sum i avg, pristup redu preko sintakse
# t.prvakolona.vrijednostkolone map, select i reduce za kolonu
p tabela.bar 
p tabela.bar.sum
p tabela.dokument.avg
p tabela.foo.vuk
p tabela.foo.map {|s| s.upcase}
p tabela.foo.select {|s| s.length > 5}
p tabela.dokument.reduce(0) {|result, s| result + s.to_i }

print "\n"

#sabiranje dvije tabele
tabela + tabela2
tabela.matrixBack.each do |row|
    p row
end
print "\n"
#oduzimanje dvije tabele
#tabela - tabela2
tabela.matrixBack.each do |row|
    p row
end
ws.reload
