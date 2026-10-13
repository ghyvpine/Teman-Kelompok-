import 'package:flutter/material.dart';
import '../constants.dart';
import '../data.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  bool _hanyaButuh = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final q = _query.toLowerCase();
        final hasil = store.projects.where((p) {
          if (_hanyaButuh && p.penuh) return false;
          if (q.isEmpty) return true;
          return p.nama.toLowerCase().contains(q) ||
              p.matkul.toLowerCase().contains(q) ||
              p.skill.toLowerCase().contains(q);
        }).toList();

        OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c, width: w));

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cari Kelompok',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v.trim()),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari mata kuliah atau skill...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: context.cSurface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: border(context.cBorder),
                  enabledBorder: border(context.cBorder),
                  focusedBorder: border(kPrimary, 1.6),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Masih butuh anggota'),
                    selected: _hanyaButuh,
                    selectedColor: context.cSoft,
                    checkmarkColor: context.cAccent,
                    onSelected: (v) => setState(() => _hanyaButuh = v),
                  ),
                  const Spacer(),
                  Text('${hasil.length} proyek',
                      style: TextStyle(color: context.cMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: hasil.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: context.cMuted.withOpacity(0.6)),
                            const SizedBox(height: 8),
                            Text('Proyek tidak ditemukan',
                                style: TextStyle(color: context.cMuted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: hasil.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _ProjectCard(project: hasil[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: context.cSoft, borderRadius: BorderRadius.circular(8)),
            child: Text(p.matkul,
                style: TextStyle(
                    color: context.cAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(p.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            p.penuh ? 'Anggota sudah penuh' : 'Membutuhkan ${p.sisa} anggota',
            style: TextStyle(
                color: p.penuh ? context.cMuted : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text('Skill: ${p.skill}', style: TextStyle(color: context.cBody, fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => DetailPage(project: p))),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.cAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Lihat Detail', style: TextStyle(color: context.cAccent)),
            ),
          ),
        ],
      ),
    );
  }
}
