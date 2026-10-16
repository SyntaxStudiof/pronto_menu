import 'dart:math';

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;
  final String funFact;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.funFact,
  });

  /// Restituisce una copia con le opzioni mescolate (per non avere sempre la risposta nella stessa posizione)
  QuizQuestion shuffled() {
    final correctAnswer = options[correctIndex];
    final shuffledOptions = List<String>.from(options)..shuffle(Random());
    final newCorrectIndex = shuffledOptions.indexOf(correctAnswer);
    return QuizQuestion(
      id: id,
      question: question,
      options: shuffledOptions,
      correctIndex: newCorrectIndex,
      category: category,
      funFact: funFact,
    );
  }
}

class QuizDataService {
  static const List<QuizQuestion> allQuestions = [
    // --- CIBO & ENOGASTRONOMIA ---
    QuizQuestion(
      id: 1,
      category: 'Cucina & Sapori 🍕',
      question: 'Qual è l\'erba aromatica fondamentale per il vero pesto alla genovese?',
      options: ['Basilico genovese DOP', 'Prezzemolo riccio', 'Origano di montagna', 'Maggiorana fresca'],
      correctIndex: 0,
      funFact: 'La ricetta ufficiale del Consorzio del Pesto Genovese ammette rigorosamente solo 7 ingredienti!',
    ),
    QuizQuestion(
      id: 2,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale formaggio DOP è l\'unico ingrediente caseario tradizionale della vera Carbonara?',
      options: ['Pecorino Romano DOP', 'Parmigiano Reggiano', 'Grana Padano', 'Ricotta Salata'],
      correctIndex: 0,
      funFact: 'Il pecorino romano unito al tuorlo crea la mitica cremina setosa senza aggiunta di panna!',
    ),
    QuizQuestion(
      id: 3,
      category: 'Cucina & Sapori 🍕',
      question: 'Da quale paese ha avuto storicamente origine il croissant prima di diffondersi in Francia?',
      options: ['Austria (Vienna)', 'Belgio (Bruxelles)', 'Svizzera (Zurigo)', 'Germania (Monaco)'],
      correctIndex: 0,
      funFact: 'Il croissant deriva dal "Kipferl" viennese, creato per celebrare la sconfitta degli ottomani nel 1683!',
    ),
    QuizQuestion(
      id: 4,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale formaggio fresco e cremoso è alla base della ricetta originale del Tiramisù?',
      options: ['Mascarpone', 'Robiola', 'Philadelphia', 'Ricotta di pecora'],
      correctIndex: 0,
      funFact: 'Il Tiramisù è nato in Veneto/Friuli negli anni \'60 ed è oggi il dolce italiano più celebre al mondo!',
    ),
    QuizQuestion(
      id: 5,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale preziosa spezia dona il tipico colore dorato al Risotto alla Milanese?',
      options: ['Zafferano', 'Curcuma', 'Curry dolce', 'Paprika gialla'],
      correctIndex: 0,
      funFact: 'Per produrre un solo chilogrammo di zafferano servono oltre 150.000 stimmi raccolti a mano!',
    ),
    QuizQuestion(
      id: 6,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale legume è l\'ingrediente protagonista del celebre Hummus mediorientale?',
      options: ['Ceci', 'Fagioli cannellini', 'Lenticchie rosse', 'Fave novelle'],
      correctIndex: 0,
      funFact: 'La parola "Hummus" in arabo significa letteralmente "ceci"!',
    ),
    QuizQuestion(
      id: 7,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale vitigno autoctono è alla base del prestigioso vino Brunello di Montalcino?',
      options: ['Sangiovese grosso', 'Nebbiolo', 'Barbera', 'Montepulciano'],
      correctIndex: 0,
      funFact: 'Il Brunello deve invecchiare per legge almeno 5 anni prima della commercializzazione!',
    ),
    QuizQuestion(
      id: 8,
      category: 'Cucina & Sapori 🍕',
      question: 'Qual è il salume tipico calabrese morbido e piccante a base di maiale e peperoncino?',
      options: ['\'Nduja', 'Soppressata', 'Capocollo', 'Culatello'],
      correctIndex: 0,
      funFact: 'Originaria di Spilinga (VV), la \'nduja si spalma calda sul pane bruschettato o si fonde nei sughi!',
    ),
    QuizQuestion(
      id: 9,
      category: 'Cucina & Sapori 🍕',
      question: 'Qual è la temperatura ideale consigliata per servire una birra bionda lager rinfrescante?',
      options: ['Tra i 4°C e i 6°C', 'Tra 0°C e 1°C', 'Tra 10°C e 12°C', 'A temperatura ambiente'],
      correctIndex: 0,
      funFact: 'Se la birra è troppo fredda le papille gustative si anestetizzano e si perdono i profumi del malto!',
    ),
    QuizQuestion(
      id: 10,
      category: 'Cucina & Sapori 🍕',
      question: 'In quale regione italiana sono nati i deliziosi Arancini (o Arancine) di riso?',
      options: ['Sicilia', 'Campania', 'Puglia', 'Calabria'],
      correctIndex: 0,
      funFact: 'A Palermo si chiamano al femminile "Arancine" (a sfera), a Catania al maschile "Arancini" (a punta)!',
    ),
    QuizQuestion(
      id: 11,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale pasta fresca ripiena è la regina indiscussa del pranzo di Natale bolognese?',
      options: ['Tortellini in brodo', 'Agnolotti al sugo', 'Ravioli ricotta e spinaci', 'Culurgiones'],
      correctIndex: 0,
      funFact: 'La leggenda vuole che la forma del tortellino sia ispirata all\'ombelico della dea Venere!',
    ),
    QuizQuestion(
      id: 12,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale bevanda alcolica è la base essenziale per preparare un autentico Mojito?',
      options: ['Rum bianco', 'Vodka pura', 'Tequila silver', 'Gin dry'],
      correctIndex: 0,
      funFact: 'Il Mojito è nato a Cuba ed era uno dei cocktail preferiti dello scrittore Ernest Hemingway!',
    ),

    // --- CURIOSITÀ DAL MONDO ---
    QuizQuestion(
      id: 13,
      category: 'Curiosità dal Mondo 🌍',
      question: 'In quale città europea si trova la celebre basilica incompiuta della Sagrada Família?',
      options: ['Barcellona', 'Madrid', 'Siviglia', 'Valencia'],
      correctIndex: 0,
      funFact: 'Progettata da Antoni Gaudí nel 1882, la sua costruzione è finanziata esclusivamente da donazioni e biglietti!',
    ),
    QuizQuestion(
      id: 14,
      category: 'Curiosità dal Mondo 🌍',
      question: 'Qual è l\'unico mammifero vivente capace di volare battendo le ali?',
      options: ['Il pipistrello', 'Lo scoiattolo volante', 'Il lemure volante', 'L\'ornitorinco'],
      correctIndex: 0,
      funFact: 'Gli scoiattoli volanti in realtà planano; solo i chirotteri (pipistrelli) possiedono il volo battuto!',
    ),
    QuizQuestion(
      id: 15,
      category: 'Curiosità dal Mondo 🌍',
      question: 'Qual è la montagna più alta della Terra calcolata dal livello del mare?',
      options: ['Monte Everest (8.848 m)', 'K2 (8.611 m)', 'Kangchenjunga (8.586 m)', 'Monte Bianco (4.808 m)'],
      correctIndex: 0,
      funFact: 'L\'Everest cresce di circa 4 millimetri all\'anno a causa della collisione delle placche tettoniche!',
    ),
    QuizQuestion(
      id: 16,
      category: 'Curiosità dal Mondo 🌍',
      question: 'Quanti tasti bianchi e neri compongono una tastiera standard di pianoforte?',
      options: ['88 tasti', '76 tasti', '64 tasti', '100 tasti'],
      correctIndex: 0,
      funFact: 'Ci sono esattamente 52 tasti bianchi (note naturali) e 36 tasti neri (diesis/bemolli)!',
    ),
    QuizQuestion(
      id: 17,
      category: 'Curiosità dal Mondo 🌍',
      question: 'In quale nazione si trova l\'antica e maestosa città scavata nella roccia di Petra?',
      options: ['Giordania', 'Egitto', 'Turchia', 'Oman'],
      correctIndex: 0,
      funFact: 'Petra è stata eletta una delle Nuove Sette Meraviglie del Mondo ed è scolpita nell\'arenaria rosa!',
    ),
    QuizQuestion(
      id: 18,
      category: 'Curiosità dal Mondo 🌍',
      question: 'Qual è l\'oceano più grande e profondo del nostro pianeta?',
      options: ['Oceano Pacifico', 'Oceano Atlantico', 'Oceano Indiano', 'Oceano Artico'],
      correctIndex: 0,
      funFact: 'L\'Oceano Pacifico copre oltre il 30% della superficie terrestre, più di tutte le terre emerse messe insieme!',
    ),

    // --- CINEMA & MUSICA ---
    QuizQuestion(
      id: 19,
      category: 'Cinema & Canzoni 🎬',
      question: 'Chi interpretava l\'iconico personaggio di Jack Dawson nel film Titanic (1997)?',
      options: ['Leonardo DiCaprio', 'Brad Pitt', 'Johnny Depp', 'Tom Cruise'],
      correctIndex: 0,
      funFact: 'Il film ha vinto ben 11 premi Oscar, record condiviso con Ben-Hur e Il Signore degli Anelli!',
    ),
    QuizQuestion(
      id: 20,
      category: 'Cinema & Canzoni 🎬',
      question: 'Quale cantautore italiano ha trionfato a Sanremo nel 1958 cantando "Nel blu dipinto di blu"?',
      options: ['Domenico Modugno', 'Adriano Celentano', 'Lucio Dalla', 'Claudio Villa'],
      correctIndex: 0,
      funFact: '"Volare" è il brano italiano più ascoltato e tradotto al mondo, con cover in oltre 30 lingue!',
    ),
    QuizQuestion(
      id: 21,
      category: 'Cinema & Canzoni 🎬',
      question: 'Chi è il geniale regista di capolavori come Pulp Fiction, Kill Bill e Django Unchained?',
      options: ['Quentin Tarantino', 'Martin Scorsese', 'Steven Spielberg', 'Christopher Nolan'],
      correctIndex: 0,
      funFact: 'Tarantino ha dichiarato che girerà esattamente 10 film nella sua carriera prima di ritirarsi!',
    ),
    QuizQuestion(
      id: 22,
      category: 'Cinema & Canzoni 🎬',
      question: 'Quale celebre gruppo rock britannico ha pubblicato lo storico album "Abbey Road"?',
      options: ['The Beatles', 'The Rolling Stones', 'Queen', 'Pink Floyd'],
      correctIndex: 0,
      funFact: 'Le strisce pedonali di Abbey Road a Londra sono state dichiarate patrimonio culturale tutelato!',
    ),
    QuizQuestion(
      id: 23,
      category: 'Cinema & Canzoni 🎬',
      question: 'Qual è il nome dell\'archeologo avventuriero con cappello e frusta interpretato da Harrison Ford?',
      options: ['Indiana Jones', 'Lara Croft', 'Nathan Drake', 'Rick O\'Connell'],
      correctIndex: 0,
      funFact: 'Il cane di George Lucas si chiamava "Indiana", e fu proprio lui a ispirare il nome del protagonista!',
    ),

    // --- CULTURA GENERALE & DIVERTIMENTO ---
    QuizQuestion(
      id: 24,
      category: 'Cervelloni & Logica 🧠',
      question: 'Quale pianeta del Sistema Solare è popolarmente noto come il "Pianeta Rosso"?',
      options: ['Marte', 'Venere', 'Giove', 'Mercurio'],
      correctIndex: 0,
      funFact: 'Il caratteristico colore rosso di Marte è dovuto alla grande presenza di ossido di ferro (ruggine) sulla superficie!',
    ),
    QuizQuestion(
      id: 25,
      category: 'Cervelloni & Logica 🧠',
      question: 'Quanti secondi ci sono esattamente in un\'ora?',
      options: ['3.600 secondi', '3.000 secondi', '6.000 secondi', '1.800 secondi'],
      correctIndex: 0,
      funFact: '60 secondi x 60 minuti = 3.600 secondi. In un giorno intero ce ne sono 86.400!',
    ),
    QuizQuestion(
      id: 26,
      category: 'Cervelloni & Logica 🧠',
      question: 'Quale elemento chimico ha il simbolo "Au" nella tavola periodica degli elementi?',
      options: ['Oro', 'Argento', 'Alluminio', 'Azoto'],
      correctIndex: 0,
      funFact: 'Il simbolo "Au" deriva dal termine latino "aurum", che significa splendore lucente!',
    ),
    QuizQuestion(
      id: 27,
      category: 'Cervelloni & Logica 🧠',
      question: 'Chi ha dipinto il celebre capolavoro "La Gioconda" esposto al Museo del Louvre di Parigi?',
      options: ['Leonardo da Vinci', 'Michelangelo Buonarroti', 'Raffaello Sanzio', 'Caravaggio'],
      correctIndex: 0,
      funFact: 'Il quadro è dipinto su una sottile tavola di legno di pioppo e misura solo 77 per 53 centimetri!',
    ),
    QuizQuestion(
      id: 28,
      category: 'Cervelloni & Logica 🧠',
      question: 'Qual è il gioco da tavolo in cui si acquistano contratti di vicoli, stazioni e società con banconote finte?',
      options: ['Monopoly', 'Risiko!', 'Cluedo', 'Trivial Pursuit'],
      correctIndex: 0,
      funFact: 'Nato nel 1935, Monopoly è stato giocato da oltre 1 miliardo di persone in tutto il mondo!',
    ),
    QuizQuestion(
      id: 29,
      category: 'Cucina & Sapori 🍕',
      question: 'Qual è la bevanda alcolica ottenuta dalla fermentazione del succo d\'uva?',
      options: ['Vino', 'Birra', 'Sidro', 'Grappa'],
      correctIndex: 0,
      funFact: 'Le prime tracce di vinificazione risalgono a oltre 8.000 anni fa nelle terre della Georgia!',
    ),
    QuizQuestion(
      id: 30,
      category: 'Cucina & Sapori 🍕',
      question: 'Quale famoso cocktail italiano è composto da Bitter Campari, Vermouth rosso e Gin in parti uguali?',
      options: ['Negroni', 'Americano', 'Aperol Spritz', 'Bellini'],
      correctIndex: 0,
      funFact: 'Fu inventato nel 1919 a Firenze dal Conte Camillo Negroni, che chiese di irrobustire il suo Americano col gin!',
    ),
  ];

  /// Pescaggio casuale di N domande uniche
  static List<QuizQuestion> getRandomQuestions({int count = 5, List<int>? specificIds}) {
    if (specificIds != null && specificIds.isNotEmpty) {
      final list = <QuizQuestion>[];
      for (final id in specificIds) {
        final q = allQuestions.firstWhere(
          (item) => item.id == id,
          orElse: () => allQuestions.first,
        );
        list.add(q.shuffled());
      }
      return list;
    }

    final shuffledAll = List<QuizQuestion>.from(allQuestions)..shuffle(Random());
    final selected = shuffledAll.take(count).map((q) => q.shuffled()).toList();
    return selected;
  }
}
