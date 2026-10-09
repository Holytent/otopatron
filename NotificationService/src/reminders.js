export const GAPS = [5,5,5,5,10];
export function messages(car) {
  return [
    car ? `${car.name} için bir müşteri ilgileniyor. Teklifi değerlendirmek için galerine dön.` : 'Yeni aracını bulmaya hazır mısın? İkinci el pazarı ve araç ilanlarını incele.',
    'Galerin seni bekliyor. Araçlarını hazırla, ilanlarını yönet ve sıradaki satışını planla.',
    car ? 'Satıştaki aracının fiyatını ve durumunu gözden geçir. Bir sonraki anlaşmaya hazır ol.' : 'Bir sonraki satışın iyi bir alımla başlar. Pazardaki araçları karşılaştır.',
    'Galerine kendi imzanı at. Tabela, zemin ve dekor seçeneklerini keşfet.',
    'Patron, yeniden direksiyona geçme zamanı. Galerine dön ve işini büyüt.'
  ];
}
